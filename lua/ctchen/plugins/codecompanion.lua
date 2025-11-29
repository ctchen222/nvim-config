return {
  "olimorris/codecompanion.nvim",
  version = "v17.33.0",
  cmd = { "CodeCompanion", "CodeCompanionChat" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    adapters = {
      -- anthropic = {
      --   api_key = os.getenv("ANTHROPIC_API_KEY"),
      -- },
    },
    strategies = {
      chat = {
        send = {
          modes = { "n", "i" },
          key = "<C-s>",
        },
        -- adapter = "anthropic",
        adapter = "copilot",
        model = "claude-sonnet-4-20250514",
      },
    },
    inline = {
      adapter = "copilot",
      model = "claude-3-haiku-20240307",
    },
  },
  keys = {
    {
      "<leader>ca",
      "<cmd>CodeCompanionActions<cr>",
      mode = { "n", "v" },
      desc = "Code Companion: Actions",
    },
    {
      "<leader>cc",
      "<cmd>CodeCompanionChat<cr>",
      desc = "Code Companion: Chat",
    },
  },
}
