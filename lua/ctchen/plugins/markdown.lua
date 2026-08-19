local function set_markdown_task_highlights()
  vim.api.nvim_set_hl(0, "MarkdownTaskTodoIcon", { fg = "#ff9e64", bold = true })
  vim.api.nvim_set_hl(0, "MarkdownTaskDoneIcon", { fg = "#9ece6a", bold = true })
  vim.api.nvim_set_hl(0, "MarkdownTaskDoneText", { fg = "#565f89", strikethrough = true })
  vim.api.nvim_set_hl(0, "MarkdownTaskWipIcon", { fg = "#e0af68", bold = true })
  vim.api.nvim_set_hl(0, "MarkdownTaskSkippedIcon", { fg = "#7aa2f7", bold = true })
  vim.api.nvim_set_hl(0, "MarkdownTaskSkippedText", { fg = "#565f89", strikethrough = true })
end

return {
  "OXY2DEV/markview.nvim",
  ft = { "markdown", "codecompanion" },
  keys = {
    { "<leader>mt", "<cmd>Markview toggle<cr>", desc = "Markdown: Toggle preview" },
    { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Markdown: Toggle split preview" },
    { "<leader>mh", "<cmd>Markview HybridToggle<cr>", desc = "Markdown: Toggle hybrid mode" },
    { "<leader>mr", "<cmd>Markview enable<cr>", desc = "Markdown: Render preview" },
    { "<leader>mc", "<cmd>Markview clear<cr>", desc = "Markdown: Clear preview" },
  },
  opts = {
    preview = {
      filetypes = { "markdown", "codecompanion" },
      ignore_buftypes = {},
      max_buf_lines = 5000,
    },
    markdown_inline = {
      checkboxes = {
        enable = true,
        unchecked = { text = "TODO", hl = "MarkdownTaskTodoIcon" },
        checked = { text = "DONE", hl = "MarkdownTaskDoneIcon", scope_hl = "MarkdownTaskDoneText" },
        ["/"] = { text = "WIP", hl = "MarkdownTaskWipIcon" },
        ["-"] = { text = "SKIP", hl = "MarkdownTaskSkippedIcon", scope_hl = "MarkdownTaskSkippedText" },
      },
    },
  },
  config = function(_, opts)
    vim.treesitter.language.register("markdown", "codecompanion")
    require("markview").setup(opts)
    set_markdown_task_highlights()

    local function configure_buffer(bufnr)
      local is_codecompanion = vim.bo[bufnr].filetype == "codecompanion"
      vim.wo.spell = not is_codecompanion
      vim.wo.wrap = not is_codecompanion
      vim.wo.linebreak = true
      vim.wo.breakindent = not is_codecompanion

      if is_codecompanion then
        vim.treesitter.start(bufnr, "markdown")
      end
    end

    local group = vim.api.nvim_create_augroup("CtchenMarkdownView", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = set_markdown_task_highlights,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "markdown", "codecompanion" },
      callback = function(args)
        configure_buffer(args.buf)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            require("markview.actions").attach(args.buf)
          end
        end)
      end,
    })

    if vim.bo.filetype == "codecompanion" then
      configure_buffer(0)
      vim.schedule(function()
        require("markview.actions").attach(0)
      end)
    end
  end,
}
