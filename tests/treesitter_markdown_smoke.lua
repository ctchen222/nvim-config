local markdown_file = vim.fs.joinpath(vim.fn.getcwd(), "README.md")

for mode, lhs in pairs({
  n = "<C-space>",
  x = "am",
}) do
  assert(vim.fn.maparg(lhs, mode) ~= "", "Missing Tree-sitter textobject mapping: " .. mode .. " " .. lhs)
end
assert(vim.fn.maparg("]m", "n") ~= "", "Missing Tree-sitter move mapping")
assert(vim.fn.maparg("<leader>na", "n") ~= "", "Missing Tree-sitter swap mapping")

vim.cmd.edit(vim.fn.fnameescape(markdown_file))
vim.cmd("redraw!")
vim.wait(200)

local messages = vim.api.nvim_exec2("messages", { output = true }).output
local treesitter_error = messages:match("Decoration provider.-nvim%.treesitter%.highlighter")
  or messages:match("treesitter%.lua:%d+: attempt to call method 'range'")

assert(not treesitter_error, messages)

local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
assert(ok, parser)
assert(#parser:parse() > 0, "Markdown parser returned no syntax trees")
