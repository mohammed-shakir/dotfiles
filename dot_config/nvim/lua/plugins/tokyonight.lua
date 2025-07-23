return {
  "folke/tokyonight.nvim",
  name = "tokyonight",
  lazy = false,
  priority = 1000,

  opts = {
    style = "night",
    transparent = false,
    terminal_colors = true,

    on_colors = function(colors)
      colors.fg_gutter = "#A0A0A0"
      colors.red = "#ff5c57"
      colors.error = colors.red
      colors.git.delete = "#ff5c57"
    end,

    on_highlights = function(hl, colors)
      -- non-current line numbers
      hl.CursorLineNr = { fg = "#ff5c57", bold = true }
      hl.LspReferenceText = { bg = colors.bg_highlight }
      hl.LspReferenceRead = { bg = colors.bg_highlight }
      hl.LspReferenceWrite = { bg = colors.bg_highlight }
      hl.IlluminatedWordText = { bg = colors.bg_highlight }
      hl.IlluminatedWordRead = { bg = colors.bg_highlight }
      hl.IlluminatedWordWrite = { bg = colors.bg_highlight }
      hl.NormalFloat = { bg = colors.bg_highlight }
      hl.FloatBorder = { fg = colors.border, bg = colors.bg_highlight }
    end,

    styles = {
      comments = { italic = false },
      keywords = { italic = true, bold = true },
      functions = { underline = true },
      variables = {},
      sidebars = "dark",
      floats = "dark",
    },

    sidebars = { "qf", "help", "terminal", "packer" },

    plugins = {
      auto = true,
    },
  },

  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd "colorscheme tokyonight"
  end,
}
