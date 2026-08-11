local root = vim.fn.getcwd()

local function assert_equal(expected, actual, message)
  if expected ~= actual then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_truthy(value, message)
  if not value then
    error(message)
  end
end

local function flatten(value)
  if type(value) == "string" then
    return value
  end
  if type(value) ~= "table" then
    return ""
  end

  local parts = {}
  for _, item in ipairs(value) do
    parts[#parts + 1] = flatten(item)
  end
  return table.concat(parts)
end

dofile(root .. "/lua/ctchen/core/options.lua")
assert_equal(3, vim.o.laststatus, "Neovim must use one global statusline")

local lualine_options
package.loaded["lualine"] = {
  setup = function(options)
    lualine_options = options
  end,
}
package.loaded["lazy.status"] = {
  updates = function()
    return ""
  end,
  has_updates = function()
    return false
  end,
}

local lualine_spec = dofile(root .. "/lua/ctchen/plugins/lualine.lua")
lualine_spec.config()
assert_truthy(lualine_options, "Lualine setup must run")
assert_equal(true, lualine_options.options.globalstatus, "Lualine must render globally")

local incline_options
package.loaded["incline"] = {
  setup = function(options)
    incline_options = options
  end,
}
package.loaded["nvim-web-devicons"] = {
  get_icon_color = function(filename)
    if filename == "example.lua" then
      return "", "#51a0cf"
    end
  end,
}

vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#fff7e8", bg = "#3a334f" })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#c3ccdc", bg = "#211c32" })

local incline_spec = dofile(root .. "/lua/ctchen/plugins/incline.lua")
assert_equal("BufReadPre", incline_spec.event, "Incline must load before a buffer is read")
incline_spec.config()

assert_truthy(incline_options, "Incline setup must run")
assert_equal("right", incline_options.window.placement.horizontal, "Incline must sit on the right")
assert_equal("top", incline_options.window.placement.vertical, "Incline must sit at the top")
assert_truthy(incline_options.highlight.groups.InclineNormal.guibg, "Active label must have a background")
assert_truthy(incline_options.highlight.groups.InclineNormalNC.guibg, "Inactive label must have a background")

local buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buffer, root .. "/example.lua")
vim.bo[buffer].modified = true

local rendered = flatten(incline_options.render({ buf = buffer, focused = true }))
assert_truthy(rendered:find("", 1, true), "Incline must render the filetype icon")
assert_truthy(rendered:find("example.lua", 1, true), "Incline must render the filename")
assert_truthy(rendered:find("●", 1, true), "Incline must render a modified marker")

local unnamed = vim.api.nvim_create_buf(true, false)
local unnamed_rendered = flatten(incline_options.render({ buf = unnamed, focused = false }))
assert_truthy(unnamed_rendered:find("[No Name]", 1, true), "Incline must label unnamed buffers")

print("streamlined Neovim UI checks passed")
vim.cmd("qa!")
