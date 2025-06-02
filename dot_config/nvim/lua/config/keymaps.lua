-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<ESC>", { silent = true })
vim.keymap.set("i", "<Up>", "<Nop>", { silent = true })
vim.keymap.set("i", "<Left>", "<Nop>", { silent = true })
vim.keymap.set("i", "<Right>", "<Nop>", { silent = true })
vim.keymap.set("i", "<Down>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Up>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Left>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Right>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Down>", "<Nop>", { silent = true })
