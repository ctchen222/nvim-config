return {
  "karb94/neoscroll.nvim",
  opts = {
    disable_default_mappings = true,
  },
  config = function()
    vim.keymap.set({ "x", "s" }, "<C-y>", "<Nop>", { silent = true, noremap = true })
  end,
}
