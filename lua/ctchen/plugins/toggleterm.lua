return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    opts = {
      size = 40, -- 預設終端窗口大小
    },
    keys = {
      -- 配置 <leader>nv：在右側垂直分割中打開終端
      {
        "<leader>nv",
        function()
          require("toggleterm.terminal").Terminal:new({ direction = "vertical", size = 40 }):toggle()
        end,
        desc = "Open Terminal (Vertical)",
      },
      -- 配置 <leader>nc：關閉終端
      {
        "<leader>nx",
        function()
          require("toggleterm").toggle(1)
        end,
        desc = "Close Terminal",
      },
      -- 配置 <leader>no：打開浮動終端
      {
        "<leader>no",
        function()
          require("toggleterm.terminal").Terminal:new({ direction = "float" }):toggle()
        end,
        desc = "Open Terminal (Float)",
      },
    },
  },
}
