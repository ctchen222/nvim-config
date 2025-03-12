return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  config = function()
    vim.g.mkdp_filetypes = { "markdown" }

    local keymap = vim.keymap

    keymap.set("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview" })
    keymap.set("n", "<leader>mo", "<cmd>MarkdownPreview<cr>", { desc = "Open markdown preview" })
    keymap.set("n", "<leader>mc", "<cmd>MarkdownPreviewStop<cr>", { desc = "Close markdown preview" })
  end,
  ft = { "markdown" },
}
