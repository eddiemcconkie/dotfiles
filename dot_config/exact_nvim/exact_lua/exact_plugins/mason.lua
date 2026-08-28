return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        'gdtoolkit' -- Formatting is bugged
      }
    },
    -- opts = function(_, opts)
    --   -- Ensure gdtoolkit is in your mason layout
    --   opts.ensure_installed = opts.ensure_installed or {}
    --   vim.list_extend(opts.ensure_installed, { "gdtoolkit" })
    -- end,
  },
}
