---@type LazySpec[]
return {
  {
    "ahmedkhalf/project.nvim", -- The project management plugin
    event = "VeryLazy", -- Lazy-load on idle
    dependencies = {
      "nvim-telescope/telescope.nvim", -- ensure Telescope is installed
    },
    opts = {
      manual_mode = false, -- auto-change root
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "Makefile", "package.json" },
      show_hidden = true,
      silent_chdir = true,
      scope_chdir = "global",
    },
    config = function(_, opts)
      -- project.nvim setup
      require("project_nvim").setup(opts)

      -- Telescope integration (guarded so it won't blow up if Telescope fails)
      local ok, telescope = pcall(require, "telescope")
      if ok then telescope.load_extension "projects" end
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find Project" },
    },
  },
}
