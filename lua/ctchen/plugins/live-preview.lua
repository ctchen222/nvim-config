return {
  "brianhuster/live-preview.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    {
      "<leader>lt",
      function()
        local livepreview = require("livepreview")

        if livepreview.is_running() then
          vim.cmd("LivePreview close")
        else
          vim.cmd("LivePreview start")
        end
      end,
      desc = "LivePreview: Toggle",
    },
    { "<leader>ls", "<cmd>LivePreview start<cr>", desc = "LivePreview: Start" },
    { "<leader>lc", "<cmd>LivePreview close<cr>", desc = "LivePreview: Close" },
    { "<leader>lp", "<cmd>LivePreview pick<cr>", desc = "LivePreview: Pick file" },
    { "<leader>lh", "<cmd>LivePreview help<cr>", desc = "LivePreview: Help" },
  },
}
