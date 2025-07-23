local function put_and_indent(opts)
  if opts.above then
    vim.cmd "put!"
  else
    vim.cmd "put"
  end
  vim.cmd "normal! `[V`]="
end

-- Black-hole delete mappings for Normal mode
local bh = {
  ["d"] = { '"_d', desc = "Delete without yanking" },
  ["dd"] = { '"_dd', desc = "Delete line without yanking" },
  ["x"] = { '"_x', desc = "Delete char without yanking" },
}

-- Black-hole delete mappings for Visual mode
local bh_v = {
  ["d"] = { '"_d', desc = "Delete selection without yanking" },
  ["x"] = { '"_x', desc = "Delete selection without yanking" },
}

local disable_arrows = {
  ["<Up>"] = { "<Nop>", desc = "Disable Up arrow" },
  ["<Down>"] = { "<Nop>", desc = "Disable Down arrow" },
  ["<Left>"] = { "<Nop>", desc = "Disable Left arrow" },
  ["<Right>"] = { "<Nop>", desc = "Disable Right arrow" },
}

return {
  {
    "AstroNvim/astrocore",
    lazy = false,
    priority = 10000,
    init = function() vim.opt.mouse = "" end,
    opts = {
      mappings = {
        n = vim.tbl_extend("force", disable_arrows, bh, {
          ["gp"] = {
            function() put_and_indent { above = false } end,
            desc = "Put below and re-indent",
          },
          ["gP"] = {
            function() put_and_indent { above = true } end,
            desc = "Put above and re-indent",
          },
          -- Split navigation
          ["<C-h>"] = { "<C-w>h", desc = "Move to left split" },
          ["<C-j>"] = { "<C-w>j", desc = "Move to below split" },
          ["<C-k>"] = { "<C-w>k", desc = "Move to above split" },
          ["<C-l>"] = { "<C-w>l", desc = "Move to right split" },

          -- Cycle buffers
          ["<Tab>"] = { ":bn<CR>", desc = "Next buffer" },
          ["<S-Tab>"] = { ":bp<CR>", desc = "Previous buffer" },

          -- LSP shortcuts
          ["K"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Hover documentation" },
          ["<leader>rn"] = { "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename symbol" },

          -- Keep cursor centered
          ["<C-d>"] = { "<C-d>zz", desc = "Scroll down and center" },
          ["<C-u>"] = { "<C-u>zz", desc = "Scroll up and center" },
          ["n"] = { "nzzzv", desc = "Next search and center" },
          ["N"] = { "Nzzzv", desc = "Previous search and center" },
        }),
        v = vim.tbl_extend("force", disable_arrows, bh_v),
        i = disable_arrows,
        o = disable_arrows,
        x = disable_arrows,
      },
    },
  },
}
