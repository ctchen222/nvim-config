---
name: lua-neovim-expert
description: Expert assistance for Lua programming and Neovim plugin development. This skill should be used when working with Neovim configuration (init.lua, lazy.nvim plugins), developing Neovim plugins, debugging Lua code in Neovim, or understanding Neovim APIs. Triggers on Lua files in Neovim config directories, plugin development tasks, lazy.nvim configuration, or Neovim API questions.
---

# Lua Neovim Expert

## Overview

This skill provides expert-level assistance for Lua programming within the Neovim ecosystem. It covers plugin development, configuration management with lazy.nvim, debugging techniques, and deep knowledge of Neovim's Lua API.

## Core Capabilities

### 1. Plugin Development

To create a new Neovim plugin, use the scaffold script:

```bash
scripts/scaffold_plugin.py <plugin-name> --path <output-directory>
```

**Standard plugin structure:**

```
plugin-name/
├── lua/
│   └── plugin-name/
│       ├── init.lua        # Main entry point, setup() function
│       ├── config.lua      # Default configuration
│       ├── commands.lua    # User commands
│       ├── autocmds.lua    # Autocommands
│       └── utils.lua       # Helper functions
├── plugin/
│   └── plugin-name.lua     # Lazy-load trigger (optional)
├── doc/
│   └── plugin-name.txt     # Vimdoc help file
├── tests/
│   └── plugin_spec.lua     # Plenary tests
├── README.md
└── LICENSE
```

**Plugin entry point pattern (lua/plugin-name/init.lua):**

```lua
local M = {}

M.config = {
  -- Default options
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  -- Initialize plugin
end

return M
```

### 2. lazy.nvim Configuration

**Plugin spec structure:**

```lua
{
  "author/plugin-name",
  dependencies = { "dependency/plugin" },
  event = "VeryLazy",           -- Lazy load on event
  ft = { "lua", "python" },     -- Lazy load on filetype
  cmd = { "Command" },          -- Lazy load on command
  keys = {                      -- Lazy load on keymap
    { "<leader>p", "<cmd>Command<cr>", desc = "Description" },
  },
  opts = {},                    -- Passed to setup()
  config = function(_, opts)    -- Custom config function
    require("plugin").setup(opts)
  end,
  init = function()             -- Runs at startup (before load)
    -- Set globals, options before plugin loads
  end,
  build = "make",               -- Build command after install
  enabled = true,               -- Conditionally enable
  cond = function()             -- Conditional loading
    return vim.fn.executable("node") == 1
  end,
  priority = 1000,              -- Load order (higher = earlier)
}
```

**Lazy loading strategies (prefer in this order):**

1. `event = "VeryLazy"` - After UI renders (safest default)
2. `event = { "BufReadPost", "BufNewFile" }` - When opening files
3. `ft = "lua"` - Filetype-specific plugins
4. `cmd = "Command"` - Command-triggered plugins
5. `keys = { ... }` - Keymap-triggered plugins

For detailed lazy.nvim patterns, refer to `references/lazy-patterns.md`.

### 3. Neovim API Usage

**Key API namespaces:**

| Namespace | Purpose |
|-----------|---------|
| `vim.api` | Core Neovim API functions (nvim_*) |
| `vim.fn` | Vimscript functions |
| `vim.opt` | Options (set equivalent) |
| `vim.g` | Global variables |
| `vim.b` | Buffer variables |
| `vim.w` | Window variables |
| `vim.keymap` | Keymap management |
| `vim.lsp` | LSP client |
| `vim.treesitter` | Treesitter API |
| `vim.diagnostic` | Diagnostics |

**Common patterns:**

```lua
-- Buffer/window/cursor operations
local bufnr = vim.api.nvim_get_current_buf()
local winnr = vim.api.nvim_get_current_win()
local cursor = vim.api.nvim_win_get_cursor(0)  -- {row, col}, 1-indexed row

-- Get/set lines
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

-- Create keymaps
vim.keymap.set("n", "<leader>x", function()
  -- action
end, { desc = "Description", buffer = bufnr })

-- Create user commands
vim.api.nvim_create_user_command("MyCommand", function(opts)
  -- opts.args, opts.bang, opts.range
end, { nargs = "*", bang = true, desc = "Description" })

-- Create autocommands
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("MyGroup", { clear = true }),
  pattern = "*.lua",
  callback = function(ev)
    -- ev.buf, ev.file, ev.match
  end,
})

-- Notifications
vim.notify("Message", vim.log.levels.INFO)

-- Schedule for main loop (async safety)
vim.schedule(function()
  -- Safe to call API here
end)
```

For comprehensive API reference, see `references/neovim-api.md`.

### 4. Debugging Techniques

**Print debugging:**

```lua
-- Basic print (goes to :messages)
print(vim.inspect(value))

-- Notification (visible in UI)
vim.notify(vim.inspect(value), vim.log.levels.DEBUG)

-- Write to file
local f = io.open("/tmp/nvim-debug.log", "a")
f:write(vim.inspect(value) .. "\n")
f:close()
```

**Using DAP (Debug Adapter Protocol):**

```lua
-- Recommended: nvim-dap with local-lua-debugger-vscode
{
  "mfussenegger/nvim-dap",
  dependencies = { "jbyuki/one-small-step-for-vimkind" },
  config = function()
    local dap = require("dap")
    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
      },
    }
    dap.adapters.nlua = function(callback, config)
      callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
    end
  end,
}
```

**Common issues and solutions:**

| Issue | Cause | Solution |
|-------|-------|----------|
| `E5108: Error executing lua` | Syntax/runtime error | Check `:messages`, use `pcall()` |
| Module not found | Wrong path/name | Verify `runtimepath`, use full module path |
| Keymap not working | Conflict/wrong mode | Check `:verbose map <key>`, verify mode |
| Plugin not loading | Lazy load condition | Check `:Lazy`, verify event/ft/cmd triggers |
| Slow startup | Blocking operations | Profile with `:Lazy profile`, defer with `vim.schedule` |

**Health checks:**

```lua
-- In lua/plugin-name/health.lua
local M = {}

function M.check()
  vim.health.start("plugin-name")

  if vim.fn.executable("dependency") == 1 then
    vim.health.ok("dependency found")
  else
    vim.health.error("dependency not found", { "Install with: brew install dependency" })
  end
end

return M
```

### 5. Lua Patterns for Neovim

**Module pattern:**

```lua
local M = {}

-- Private function
local function internal_helper()
end

-- Public API
function M.public_function()
  internal_helper()
end

return M
```

**Class-like pattern with metatables:**

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(opts)
  local self = setmetatable({}, MyClass)
  self.value = opts.value or "default"
  return self
end

function MyClass:method()
  return self.value
end

return MyClass
```

**Async patterns:**

```lua
-- Using vim.loop (libuv)
local uv = vim.loop

-- Timer
local timer = uv.new_timer()
timer:start(1000, 0, vim.schedule_wrap(function()
  -- Runs after 1 second
  timer:close()
end))

-- Async job
vim.fn.jobstart({ "command", "arg" }, {
  on_stdout = function(_, data)
    vim.schedule(function()
      -- Process output
    end)
  end,
  on_exit = function(_, code)
    vim.schedule(function()
      -- Handle completion
    end)
  end,
})

-- Using plenary.async (if available)
local async = require("plenary.async")
async.run(function()
  local result = async.wrap(function(callback)
    -- async operation
    callback(nil, "result")
  end, 1)()
end)
```

**Safe requiring:**

```lua
local ok, module = pcall(require, "module-name")
if not ok then
  vim.notify("module-name not found", vim.log.levels.WARN)
  return
end
```

## Testing

**Using plenary.nvim for tests:**

```lua
-- tests/plugin_spec.lua
describe("plugin-name", function()
  local plugin = require("plugin-name")

  before_each(function()
    plugin.setup({})
  end)

  it("should have default config", function()
    assert.is_not_nil(plugin.config)
  end)

  it("should merge user config", function()
    plugin.setup({ option = "value" })
    assert.equals("value", plugin.config.option)
  end)
end)
```

Run tests: `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`

## Resources

### scripts/
- `scaffold_plugin.py` - Generate new plugin boilerplate structure

### references/
- `neovim-api.md` - Comprehensive Neovim Lua API reference
- `lazy-patterns.md` - Advanced lazy.nvim configuration patterns
