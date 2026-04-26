-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.autoindent = true
vim.o.autochdir = false

-- Force OSC 52 with tmux-specific wrapping
vim.g.clipboard = {
	name = 'OSC 52',
  -- copy = {
  --   ['+'] = function(lines)
  --     local s = table.concat(lines, '\n')
  --     local b64 = vim.base64.encode(s)
  --     -- The \ePtmux;\e prefix tells tmux to pass this through to Ghostty
  --     local osc = string.format('\27Ptmux;\27\27]52;c;%s\a\27\\', b64)
  --     io.stdout:write(osc)
  --   end,
  --   ['*'] = function(lines)
  --     local s = table.concat(lines, '\n')
  --     local b64 = vim.base64.encode(s)
  --     local osc = string.format('\27Ptmux;\27\27]52;c;%s\a\27\\', b64)
  --     io.stdout:write(osc)
  --   end,
  -- },
	copy = {
		['+'] = require('vim.ui.clipboard.osc52').copy('+'),
		['*'] = require('vim.ui.clipboard.osc52').copy('*'),
	},
	paste = {
		['+'] = require('vim.ui.clipboard.osc52').paste('+'),
		['*'] = require('vim.ui.clipboard.osc52').paste('*'),
	},
}

-- vim.opt.clipboard = "unnamedplus"
-- Force it after a tiny delay to beat any plugins
vim.defer_fn(function()
	vim.opt.clipboard = "unnamedplus"
end, 100)

