return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 10, total = 100 },
        easing = "linear",
      },
      animate_repeat = {
        delay = 50,
        duration = { step = 3, total = 20 },
        easing = "linear",
      },
    },
  },
}
