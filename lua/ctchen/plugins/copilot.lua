return {
  {
    "copilotc-nvim/copilotchat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- only on macos or linux
    opts = {
      -- see configuration section for options
    },
    -- see commands section for default commands if you want to lazy load on them
    keys = {
      {
        "<leader>co",
        "<cmd>CopilotChatOpen<cr>",
        desc = "Open Copilot Chat",
      },
      {
        "<leader>cc",
        "<cmd>CopilotChatClose<cr>",
        desc = "Close Copilot Chat",
      },
      {
        "<leader>ct",
        "<cmd>CopilotChatToggle<cr>",
        desc = "Toggle Copilot Chat",
      },
      {
        "<leader>cp",
        "<cmd>CopilotChatPrompts<cr>",
        desc = "Copilot Prompts",
      },
    },
  },
}
