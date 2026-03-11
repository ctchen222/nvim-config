return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")
    _99.setup({
      tmp_dir = "./tmp",
      md_files = { "AGENT.md" },
    })

    vim.keymap.set("v", "<leader>9v", _99.visual, { desc = "99: AI Replace Selection" })
    vim.keymap.set("n", "<leader>9s", _99.search, { desc = "99: AI Search" })
    vim.keymap.set("n", "<leader>9x", _99.stop_all_requests, { desc = "99: Stop All Requests" })
  end,
}
