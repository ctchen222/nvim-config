return {
  "Ramilito/kubectl.nvim",
  cmd = "Kubectl",
  keys = {
    { "<leader>K", "<cmd>lua require('kubectl').toggle()<cr>", desc = "kubectl: Toggle" },
  },
  config = function()
    require("kubectl").setup({
      auto_refresh = {
        enabled = true,
        interval = 300, -- ms
      },
      diff = {
        bin = "kubectl",
      },
      kubectl_cmd = { cmd = "kubectl", env = {}, args = {} },
      log_level = vim.log.levels.INFO,
      float_size = {
        width = 0.9,
        height = 0.8,
        col = 10,
        row = 5,
      },
      obj_fresh = 5, -- highlight new objects within N minutes
    })
  end,
}
