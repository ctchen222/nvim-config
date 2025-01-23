return {
  "crnvl96/lazydocker.nvim",
  cmd = {
    "LazyDocker",
    "LazyDockerConfig",
  },
  dependencies = {
    "MunifTanjim/nui.nvim", -- 必須依賴
  },
  keys = {
    { "<leader>ld", "<cmd>LazyDocker<cr>", desc = "Open LazyDocker" },
  },
  config = function()
    require("lazydocker").setup({
      terminal = {
        direction = "float", -- 終端顯示方式: "float", "horizontal", 或 "vertical"
        float_opts = {
          border = "rounded", -- 浮動窗口邊框樣式
        },
      },
    })
  end,
}
