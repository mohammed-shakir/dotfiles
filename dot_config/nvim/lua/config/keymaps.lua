-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Normal Mode
vim.keymap.set("n", "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char without yanking" })
vim.keymap.set("n", "gp", "p==", { desc = "Put below and re-indent" })
vim.keymap.set("n", "gP", "P==", { desc = "Put above and re-indent" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover documentation" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
-- Save session to disk
vim.keymap.set("n", "<leader>ss", function()
  vim.cmd("Psave")
end, { desc = "Save Session" })
-- Delete session
vim.keymap.set("n", "<leader>sd", function()
  vim.cmd("Pdelete")
end, { desc = "Delete Session" })

-- Visual Mode
vim.keymap.set("v", "d", '"_d', { desc = "Delete selection without yanking" })
vim.keymap.set("v", "x", '"_x', { desc = "Delete selection without yanking" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- Disable arrow keys in all modes
for _, mode in ipairs({ "n", "v", "i", "o", "x" }) do
  vim.keymap.set(mode, "<Up>", "<Nop>")
  vim.keymap.set(mode, "<Down>", "<Nop>")
  vim.keymap.set(mode, "<Left>", "<Nop>")
  vim.keymap.set(mode, "<Right>", "<Nop>")
end
