return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    -- =====================
    -- Workspaces 設定
    -- =====================
    -- 可以設定多個 vault，obsidian.nvim 會自動偵測當前檔案屬於哪個 workspace
    workspaces = {
      {
        name = "notes",
        path = "~/notes",
      },
      -- 可以新增更多 workspace:
      -- {
      --   name = "work",
      --   path = "~/work-notes",
      -- },
    },

    -- =====================
    -- 筆記設定
    -- =====================
    -- 新筆記存放位置: "current_dir" | "notes_subdir"
    new_notes_location = "current_dir",

    -- 筆記 ID 生成方式 (預設用時間戳)
    note_id_func = function(title)
      -- 如果有標題就用標題，沒有就用時間戳
      if title ~= nil then
        -- 將空格轉為連字號，保留中文和其他 Unicode 字元
        -- 只移除檔案系統不允許的字元: / \ : * ? " < > |
        return title:gsub(" ", "-"):gsub('[/\\:*?"<>|]', "")
      else
        return tostring(os.time())
      end
    end,

    -- 偏好的連結風格: "wiki" ([[link]]) 或 "markdown" ([link](path))
    preferred_link_style = "wiki",

    -- =====================
    -- Daily Notes 每日筆記
    -- =====================
    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
      alias_format = "%B %d, %Y",
      default_tags = { "daily" },
      template = "daily.md", -- 使用 daily 模板
    },

    -- =====================
    -- Templates 模板
    -- =====================
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- 自訂替換變數
      substitutions = {
        yesterday = function()
          return os.date("%Y-%m-%d", os.time() - 86400)
        end,
        tomorrow = function()
          return os.date("%Y-%m-%d", os.time() + 86400)
        end,
      },
    },

    -- =====================
    -- 自動補全
    -- =====================
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    -- =====================
    -- UI 設定
    -- =====================
    ui = {
      enable = true,
      update_debounce = 200,
      max_file_length = 5000,
      -- checkbox 樣式
      checkboxes = {
        [" "] = { char = "☐", hl_group = "ObsidianTodo" },
        ["x"] = { char = "✔", hl_group = "ObsidianDone" },
        [">"] = { char = "➜", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "☒", hl_group = "ObsidianTilde" },
      },
      bullets = { char = "•", hl_group = "ObsidianBullet" },
      external_link_icon = { char = "🔗", hl_group = "ObsidianExtLinkIcon" },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = "#f78c6c" },
        ObsidianDone = { bold = true, fg = "#89ddff" },
        ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
        ObsidianTilde = { bold = true, fg = "#ff5370" },
        ObsidianBullet = { bold = true, fg = "#89ddff" },
        ObsidianRefText = { underline = true, fg = "#c792ea" },
        ObsidianExtLinkIcon = { fg = "#c792ea" },
        ObsidianTag = { italic = true, fg = "#89ddff" },
        ObsidianBlockID = { italic = true, fg = "#89ddff" },
        ObsidianHighlightText = { bg = "#75662e" },
      },
    },

    -- =====================
    -- 圖片/附件設定
    -- =====================
    attachments = {
      img_folder = "assets/imgs",
      img_name_func = function()
        return string.format("%s-", os.time())
      end,
    },

    -- =====================
    -- Picker 設定 (使用 Telescope)
    -- =====================
    picker = {
      name = "telescope.nvim",
      note_mappings = {
        new = "<C-x>", -- 在 picker 中建立新筆記
        insert_link = "<C-l>", -- 插入連結
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-l>",
      },
    },

    -- =====================
    -- 其他設定
    -- =====================
    -- 開啟筆記的方式: "current" | "vsplit" | "hsplit"
    open_notes_in = "current",

    -- 排序方式
    sort_by = "modified",
    sort_reversed = true,

    -- 搜尋設定
    search_max_lines = 1000,

    -- 在 Obsidian app 中開啟 (macOS)
    open_app_foreground = false,

    -- =====================
    -- 快捷鍵設定 (buffer local)
    -- =====================
    mappings = {
      -- gf: 跟隨連結 (覆蓋 vim 預設的 gf)
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- <CR>: 智慧動作 (在連結上按 Enter 會跟隨，在 checkbox 上會切換)
      ["<CR>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
      -- <leader>ch: 切換 checkbox
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
    },
  },
  keys = {
    -- =====================
    -- 全域快捷鍵
    -- =====================
    -- 搜尋筆記
    { "<leader>nf", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian: Find note" },
    { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Obsidian: Search in notes" },

    -- 建立筆記
    { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "Obsidian: New note" },
    { "<leader>nt", "<cmd>ObsidianNewFromTemplate<cr>", desc = "Obsidian: New from template" },

    -- Daily notes
    { "<leader>nd", "<cmd>ObsidianToday<cr>", desc = "Obsidian: Today's note" },
    { "<leader>ny", "<cmd>ObsidianYesterday<cr>", desc = "Obsidian: Yesterday's note" },
    { "<leader>nm", "<cmd>ObsidianTomorrow<cr>", desc = "Obsidian: Tomorrow's note" },

    -- 連結相關
    { "<leader>nl", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Obsidian: Link selection" },
    { "<leader>nL", "<cmd>ObsidianLinkNew<cr>", mode = "v", desc = "Obsidian: Link to new note" },
    { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian: Show backlinks" },
    { "<leader>nk", "<cmd>ObsidianLinks<cr>", desc = "Obsidian: Show all links" },

    -- 其他
    { "<leader>no", "<cmd>ObsidianOpen<cr>", desc = "Obsidian: Open in app" },
    { "<leader>np", "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian: Paste image" },
    { "<leader>nr", "<cmd>ObsidianRename<cr>", desc = "Obsidian: Rename note" },
    { "<leader>ni", "<cmd>ObsidianTemplate<cr>", desc = "Obsidian: Insert template" },
    { "<leader>n#", "<cmd>ObsidianTags<cr>", desc = "Obsidian: Browse tags" },
    { "<leader>nc", "<cmd>ObsidianTOC<cr>", desc = "Obsidian: Table of contents" },
  },
}
