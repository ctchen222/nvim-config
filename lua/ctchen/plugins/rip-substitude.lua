return {
  "chrisgrieser/nvim-rip-substitute",
  config = function()
    local rip_substitute = require("rip-substitute")
    rip_substitute.setup()

    vim.keymap.set("x", "<leader>fs", function()
      rip_substitute.sub()
    end, { desc = "rip substitute" })
  end,
}
