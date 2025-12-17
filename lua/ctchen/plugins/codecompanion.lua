return {
  {
    "olimorris/codecompanion.nvim",
    -- dir = "/Users/ctchen/Development/open-source/codecompanion.nvim",
    version = "v17.33.0",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    ft = { "codecompanion" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      language = "Tranditional Chinese",
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
          model = "claude-sonnet-4-5-20250929",
          -- language = "繁體中文",
        },
        inline = {
          adapter = "copilot",
          model = "claude-sonnet-4-5-20250929",
        },
      },
      inline = {
        adapter = "copilot",
        model = "claude-sonnet-4-5-20250929",
        keymaps = {
          accept_change = {
            modes = { n = "gda", v = "ga" },
            description = "Accept change (all in normal, selection in visual)",
          },
          reject_change = {
            modes = { n = "gdr", v = "gr" },
            opts = { nowait = true },
            description = "Reject change (all in normal, selection in visual)",
          },
        },
        show_keymaps = true,
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
      {
        "<leader>ct",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "Code Companion: Toggle",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
