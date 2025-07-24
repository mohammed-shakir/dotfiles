return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.codelens = opts.codelens or {}
      opts.codelens.enabled = true
      return opts
    end,
  },
}
