---@type LazySpec
return {
  {
    "echasnovski/mini.icons", -- Icon provider
    version = false, -- Use latest commits
    config = function()
      require("mini.icons").setup {
        -- Optional: choose 'ascii' style or configure symbol_map here
        style = "glyph",
      }
    end,
    dependencies = { -- Ensure icons support in other plugins
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
  },
}
