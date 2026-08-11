return {
  "b0o/incline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "BufReadPre",
  priority = 1200,
  config = function()
    local devicons = require("nvim-web-devicons")

    local function highlight_color(group, attribute, fallback)
      local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
      local value = highlight[attribute]
      return value and string.format("#%06x", value) or fallback
    end

    local active_background = highlight_color("PmenuSel", "bg", "#3A334F")
    local active_foreground = highlight_color("PmenuSel", "fg", "#FFF7E8")
    local inactive_background = highlight_color("NormalFloat", "bg", "#211C32")
    local inactive_foreground = highlight_color("NormalFloat", "fg", "#C3CCDC")

    require("incline").setup({
      highlight = {
        groups = {
          InclineNormal = {
            guibg = active_background,
            guifg = active_foreground,
          },
          InclineNormalNC = {
            guibg = inactive_background,
            guifg = inactive_foreground,
          },
        },
      },
      window = {
        margin = { horizontal = 1, vertical = 0 },
        padding = 0,
        placement = { horizontal = "right", vertical = "top" },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end

        local icon, icon_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified

        return {
          " ",
          icon and { icon, guifg = icon_color } or "",
          icon and " " or "",
          { filename, gui = props.focused and "bold" or nil },
          modified and { " ●", guifg = "#FFDA7B" } or "",
          " ",
        }
      end,
    })
  end,
}
