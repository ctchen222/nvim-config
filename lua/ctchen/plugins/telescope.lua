return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local action_layout = require("telescope.actions.layout")

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.45,
          },
          vertical = {
            mirror = false,
            preview_height = 0.5,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },

        borderchars = {
          prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
          preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },

        winblend = 0,

        path_display = { "truncate" },
        file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },

        preview = {
          treesitter = true,
        },

        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
            ["<C-p>"] = action_layout.toggle_preview,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<Esc>"] = actions.close,
          },
          n = {
            ["q"] = actions.close,
            ["<C-p>"] = action_layout.toggle_preview,
          },
        },
      },

      pickers = {
        find_files = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.75,
            height = 0.65,
            preview_width = 0.55,
            prompt_position = "top",
          },
          hidden = true,
        },
        buffers = {
          theme = "dropdown",
          previewer = false,
          layout_config = {
            width = 0.5,
            height = 0.4,
          },
          sort_mru = true,
          ignore_current_buffer = true,
        },
        oldfiles = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.75,
            height = 0.65,
            preview_width = 0.55,
            prompt_position = "top",
          },
        },
        live_grep = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.9,
            height = 0.8,
            preview_width = 0.5,
            prompt_position = "top",
          },
        },
        grep_string = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.9,
            height = 0.8,
            preview_width = 0.5,
            prompt_position = "top",
          },
        },
        current_buffer_fuzzy_find = {
          layout_strategy = "vertical",
          layout_config = {
            width = 0.6,
            height = 0.7,
            preview_height = 0.4,
            prompt_position = "top",
          },
        },
        lsp_references = {
          theme = "cursor",
          layout_config = {
            width = 0.8,
            height = 0.4,
          },
          show_line = false,
        },
        lsp_definitions = {
          theme = "cursor",
          layout_config = {
            width = 0.8,
            height = 0.4,
          },
        },
        lsp_implementations = {
          theme = "cursor",
          layout_config = {
            width = 0.8,
            height = 0.4,
          },
        },
        lsp_document_symbols = {
          theme = "dropdown",
          layout_config = {
            width = 0.6,
            height = 0.6,
          },
        },
        diagnostics = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.9,
            height = 0.7,
            preview_width = 0.5,
            prompt_position = "top",
          },
        },
        git_commits = {
          layout_config = {
            width = 0.9,
            height = 0.8,
          },
        },
        git_status = {
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.85,
            height = 0.75,
            preview_width = 0.55,
            prompt_position = "top",
          },
        },
      },
    })

    -- local colors = {
    --   bg = "#011628",
    --   bg_dark = "#011423",
    --   bg_highlight = "#143652",
    --   border = "#547998",
    --   fg = "#CBE0F0",
    --   fg_dark = "#B4D0E9",
    --   blue = "#0A64AC",
    --   cyan = "#7dcfff",
    --   purple = "#bb9af7",
    --   green = "#9ece6a",
    -- }
    --
    -- local hl = vim.api.nvim_set_hl
    -- hl(0, "TelescopeNormal", { bg = colors.bg_dark, fg = colors.fg })
    -- hl(0, "TelescopeBorder", { bg = colors.bg_dark, fg = colors.border })
    -- hl(0, "TelescopePromptNormal", { bg = colors.bg_highlight })
    -- hl(0, "TelescopePromptBorder", { bg = colors.bg_highlight, fg = colors.bg_highlight })
    -- hl(0, "TelescopePromptTitle", { bg = colors.cyan, fg = colors.bg_dark, bold = true })
    -- hl(0, "TelescopePreviewTitle", { bg = colors.green, fg = colors.bg_dark, bold = true })
    -- hl(0, "TelescopeResultsTitle", { bg = colors.purple, fg = colors.bg_dark, bold = true })
    -- hl(0, "TelescopeSelection", { bg = colors.bg_highlight, fg = colors.fg, bold = true })
    -- hl(0, "TelescopePromptPrefix", { bg = colors.bg_highlight, fg = colors.cyan })
    -- hl(0, "TelescopeMatching", { fg = colors.cyan, bold = true })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Find definition" })
    keymap.set("n", "<leader>fD", function()
      vim.cmd("vsplit")
      require("telescope.builtin").lsp_definitions({
        theme = "dropdown",
        previewer = false,
      })
    end, { desc = "Find definition (vsplit)" })
    keymap.set("n", "<leader>fe", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })

    -- LSP code tracing
    keymap.set("n", "<leader>fT", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Find type definition" })
    keymap.set("n", "<leader>f<", "<cmd>Telescope lsp_incoming_calls<cr>", { desc = "Incoming calls" })

    -- Navigation
    keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
    keymap.set("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in buffer" })
    keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { desc = "Jumplist" })
    keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Marks" })

    -- Git
    keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git commits" })
    keymap.set("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", { desc = "Buffer commits" })
    keymap.set("n", "<leader>gS", "<cmd>Telescope git_status<cr>", { desc = "Git status" })
  end,
}
