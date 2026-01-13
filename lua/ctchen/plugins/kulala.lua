return {
  "mistweaverco/kulala.nvim",
keys = {
    { "<leader>sr", function() require("kulala").run() end, desc = "Send request" },
    { "<leader>sa", function() require("kulala").run_all() end, desc = "Send all requests" },
    { "<leader>sb", function() require("kulala").open_scratchpad() end, desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  opts = {
    global_keymaps = false,
    global_keymaps_prefix = "<leader>s",
    kulala_keymaps_prefix = "",
  },
}
