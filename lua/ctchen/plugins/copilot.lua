return {
  {
    "copilotc-nvim/copilotchat.nvim",
    -- dir = "/Users/ctchen/Development/open-source/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- only on macos or linux
    opts = {
      -- see configuration section for options
      language = "Traditional Chinese",
      headers = {
        user = "👤 User ",
        assistant = "🤖 Copilot Response ",
        tool = "🔧 Tool ",
      },
      separator = "━━",
      auto_fold = false, -- Automatically folds non-assistant messages
      window = {
        layout = "vertical", -- 'vertical', 'horizontal', 'float'
        width = 0.5, -- 50% of screen width
      },
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
      {
        "<leader>cm",
        "<cmd>CopilotChatModels<cr>",
        desc = "Copilot Models",
      },
    },
  },
}
