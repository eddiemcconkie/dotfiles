-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<CR>", "o<C-c>")
vim.keymap.set("n", "<S-CR>", "O<C-c>")

-- Move out of terminal
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-h>]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-j>]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-k>]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-l>]])

-- nvim-dap (VS Code style)
vim.keymap.set("n", "<F5>", function() require("dap").continue() end)
vim.keymap.set("n", "<F6>", function() require("dap").pause() end)
vim.keymap.set("n", "<F9>", function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end)
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end)
vim.keymap.set("n", "<S-F11>", function() require("dap").step_out() end)
vim.keymap.set("n", "<S-F5>", function() require("dap").terminate() end)
vim.keymap.set("n", "<C-S-F5>", function() require("dap").restart() end)
