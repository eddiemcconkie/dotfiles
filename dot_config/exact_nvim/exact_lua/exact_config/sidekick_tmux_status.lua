local M = {}

local group = vim.api.nvim_create_augroup("sidekick_tmux_status", { clear = true })
local timer
local job_running = false
local last_status
local current_state
local current_cwd
local did_setup = false
local acknowledged_message_id
local last_action_message_id
local last_alert = {}
local skip_next_alert = true

local STATUS = {
  idle = " #[fg=blue]●#[default]",
  busy = " #[fg=yellow]●#[default]",
  error = " #[fg=red]●#[default]",
  attention = " #[fg=green]●#[default]",
  clear = "",
}

local function sql_string(value)
  return "'" .. tostring(value):gsub("'", "''") .. "'"
end

local function set_tmux_status(status)
  if not vim.env.TMUX or not vim.env.TMUX_PANE then
    return
  end

  status = status or STATUS.clear
  if status == last_status then
    return
  end
  last_status = status

  vim.fn.jobstart({
    "tmux",
    "set-option",
    "-w",
    "-t",
    vim.env.TMUX_PANE,
    "@sidekick_status",
    status,
  }, { detach = true })
end

local function attached_opencode_cwd()
  local ok, status = pcall(require, "sidekick.status")
  if not ok then
    return nil
  end

  for _, cli in ipairs(status.cli()) do
    if cli.tool == "opencode" then
      return cli.cwd or vim.fn.getcwd(0)
    end
  end
end

local function opencode_terminal_focused()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "sidekick_terminal" then
    return false
  end

  local cli = vim.b[buf].sidekick_cli
  return type(cli) == "table" and cli.name == "opencode"
end

local function tmux_window_active()
  if not vim.env.TMUX or not vim.env.TMUX_PANE then
    return true
  end

  local output = vim.fn.system({ "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_active}" })
  return vim.v.shell_error == 0 and vim.trim(output) == "1"
end

local function opencode_terminal_active()
  return opencode_terminal_focused() and tmux_window_active()
end

local function single_ping()
  vim.fn.jobstart({
    "bash",
    "-lc",
    [[tty=$(tmux display-message -p '#{client_tty}'); [ -n "$tty" ] && printf '\a' > "$tty"]],
  }, { detach = true })
end

local function alert(kind)
  local now = vim.uv.now()
  if now - (last_alert[kind] or 0) < 2000 then
    return
  end
  last_alert[kind] = now
  single_ping()
end

local function set_state(state)
  if state == current_state then
    return
  end

  local previous = current_state
  current_state = state

  local alert_kind
  if previous == "busy" and (state == "attention" or state == "idle") then
    alert_kind = "done"
  end

  if alert_kind then
    if alert_kind == "done" and skip_next_alert then
      skip_next_alert = false
    else
      alert(alert_kind)
    end
  end

  set_tmux_status(STATUS[state] or STATUS.clear)
end

local function query_opencode_status(cwd)
  local quoted_cwd = sql_string(cwd)
  return ([[
    with active_session as (
      select id
      from session
      where directory = %s
      order by time_updated desc
      limit 1
    ),
    latest_assistant_message as (
      select id, time_created, data
      from message
      where session_id = (select id from active_session)
        and json_extract(data, '$.role') = 'assistant'
      order by time_created desc
      limit 1
    ),
    latest_user_message as (
      select id, time_created
      from message
      where session_id = (select id from active_session)
        and json_extract(data, '$.role') = 'user'
      order by time_created desc
      limit 1
    ),
    latest_parts as (
      select data
      from part
      where message_id = (select id from latest_assistant_message)
    )
    select
      (select id from active_session) as session_id,
      (select id from latest_assistant_message) as assistant_message_id,
      (select json_extract(data, '$.finish') from latest_assistant_message) as finish,
      (select time_created from latest_assistant_message) as assistant_time,
      (select time_created from latest_user_message) as user_time,
      coalesce(sum(case
        when json_extract(data, '$.tool') in ('question') then 1
        when json_extract(data, '$.state.status') = 'running'
          and json_type(data, '$.state.metadata') is null
          and json_type(data, '$.state.input') = 'object'
          and json_extract(data, '$.state.input') <> '{}'
          then 1
        else 0
      end), 0) as pending,
      case
        when coalesce(sum(case
          when json_extract(data, '$.state.status') = 'pending' then 1
          when json_extract(data, '$.state.status') = 'running'
            and coalesce(json_extract(data, '$.tool'), '') not in ('question') then 1
          else 0
        end), 0) > 0 then 1
        when coalesce(sum(case when json_extract(data, '$.type') = 'step-finish' then 1 else 0 end), 0) = 0 then 1
        else 0
      end as busy
    from latest_parts
  ]]):format(quoted_cwd)
end

local function poll_opencode()
  local cwd = attached_opencode_cwd()
  if not cwd then
    set_state("clear")
    M.stop()
    return
  end
  current_cwd = cwd

  if job_running then
    return
  end
  job_running = true

  local stdout = {}
  local stderr = {}
  vim.fn.jobstart({ "opencode", "db", query_opencode_status(cwd), "--format", "json" }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      stdout = data or {}
    end,
    on_stderr = function(_, data)
      stderr = data or {}
    end,
    on_exit = vim.schedule_wrap(function(_, code)
      job_running = false

      cwd = attached_opencode_cwd()
      if not cwd then
        set_state("clear")
        M.stop()
        return
      end

      if code ~= 0 then
        set_state("error")
        return
      end

      local output = table.concat(stdout, "\n")
      local ok, decoded = pcall(vim.json.decode, output)
      local row = ok and decoded and decoded[1] or nil
      if not row or not row.session_id then
        set_state("error")
        return
      end

      local pending = tonumber(row.pending) or 0
      local busy = tonumber(row.busy) or 0
      local assistant_message_id = row.assistant_message_id
      local assistant_time = tonumber(row.assistant_time) or 0
      local user_time = tonumber(row.user_time) or 0

      if assistant_message_id and row.finish == "stop" and opencode_terminal_active() then
        acknowledged_message_id = assistant_message_id
      end

      if pending > 0 then
        if assistant_message_id and assistant_message_id ~= last_action_message_id then
          last_action_message_id = assistant_message_id
          skip_next_alert = false
          alert("action")
        end
        set_state("error")
      elseif busy > 0 then
        set_state("busy")
      elseif
        assistant_message_id
        and row.finish == "stop"
        and assistant_message_id ~= acknowledged_message_id
        and assistant_time > user_time
      then
        set_state("attention")
      else
        set_state("idle")
      end
    end),
  })
end

function M.start()
  current_cwd = attached_opencode_cwd()
  if not current_cwd then
    set_state("clear")
    return
  end

  if current_state == "clear" or current_state == nil then
    skip_next_alert = true
  end

  if not timer then
    timer = assert(vim.uv.new_timer())
  end

  set_state("busy")
  timer:stop()
  timer:start(0, 200, vim.schedule_wrap(poll_opencode))
end

function M.stop()
  if timer then
    timer:stop()
  end
  current_cwd = nil
  acknowledged_message_id = nil
  last_action_message_id = nil
  skip_next_alert = true
  set_state("clear")
end

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "SidekickCliAttach", "SidekickCliDetach" },
    callback = function()
      vim.defer_fn(function()
        if attached_opencode_cwd() then
          M.start()
        else
          M.stop()
        end
      end, 100)
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = M.stop,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = group,
    callback = function()
      if opencode_terminal_active() then
        poll_opencode()
      end
    end,
  })

  vim.defer_fn(function()
    if attached_opencode_cwd() then
      M.start()
    end
  end, 1000)
end

return M
