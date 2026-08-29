local root = vim.fn.getcwd()

local function assert_equal(expected, actual, message)
  if expected ~= actual then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

vim.api.nvim_set_hl(0, "Normal", { fg = "#D8D1E8", bg = "#171521" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#D8D1E8", bg = "#211C32" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#9187B8", italic = true })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#E5C77A", bold = true })

local ok, error_message = pcall(function()
  local spec = dofile(root .. "/lua/ctchen/plugins/bufferline.lua")[1]
  local options = type(spec.opts) == "function" and spec.opts() or spec.opts

  assert_equal("buffers", options.options.mode, "Bufferline must preserve buffer navigation")
  assert_equal("slant", options.options.separator_style, "Bufferline must keep slanted separators")
  assert_equal(false, options.options.show_buffer_close_icons, "Buffer close icons must stay hidden")
  assert_equal(false, options.options.show_close_icon, "The global close icon must stay hidden")
  assert_equal("nvim_lsp", options.options.diagnostics, "LSP diagnostics must remain enabled")
  assert_equal(" 3", options.options.diagnostics_indicator(3), "Diagnostics must use a subdued numeric count")
  assert_equal("NvimTree", options.options.offsets[1].filetype, "The NvimTree offset must be preserved")

  assert_equal("#E5C77A", options.highlights.buffer_selected.bg, "Selected buffers must use the warm accent")
  assert_equal("#171521", options.highlights.buffer_selected.fg, "Selected buffer text must contrast with the accent")
  assert_equal(true, options.highlights.buffer_selected.bold, "Selected buffers must be bold")
  assert_equal("#211C32", options.highlights.background.bg, "Inactive buffers must use the subdued surface")
  assert_equal("#171521", options.highlights.fill.bg, "The bufferline fill must match the editor surface")
end)

if not ok then
  vim.api.nvim_err_writeln(error_message)
  vim.cmd("cquit 1")
end

print("Bufferline style checks passed")
vim.cmd("qa!")
