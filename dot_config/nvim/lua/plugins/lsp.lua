return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.codelens = opts.codelens or {}
      opts.codelens.enabled = true
      opts.diagnostics = {
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        signs = opts.diagnostics.signs,
        virtual_text = {
          spacing = 4,
          prefix = "●",
          source = "if_many",
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }
      return opts
    end,
  },
}
