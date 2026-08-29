local expected = "tokyonight-night"
local actual = vim.g.colors_name

if actual ~= expected then
  vim.api.nvim_err_writeln(string.format("expected colorscheme %s, got %s", expected, vim.inspect(actual)))
  vim.cmd("cquit 1")
end

print("TokyoNight colorscheme checks passed")
vim.cmd("qa!")
