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
    require("markview").setup(opts)
    set_markdown_task_highlights()

    local group = vim.api.nvim_create_augroup("CtchenMarkdownView", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = set_markdown_task_highlights,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "markdown", "codecompanion" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
      end,
    })
  end,
}
