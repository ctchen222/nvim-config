return {
  "yanskun/gotests.nvim",
  ft = "go",
  config = function()
    require("gotests").setup()

    vim.keymap.set({ "x", "n" }, "<leader>gt", ":GoTests<CR>", { noremap = true, silent = true })
    vim.keymap.set({ "x", "n" }, "<leader>ga", ":GoTestsAll<CR>", { noremap = true, silent = true })
  end,
}
