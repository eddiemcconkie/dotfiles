-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = true
vim.g.autoformat = false
vim.opt.fixendofline = false

vim.g.root_spec = { "cwd" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false,
    },
  },
  -- {
  --   "neolooong/whichpy.nvim",
  --   dependencies = {
  --     "mfussenegger/nvim-dap-python",
  --     "ibhagwan/fzf-lua",
  --   }
  -- },
}
