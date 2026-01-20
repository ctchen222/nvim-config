#!/usr/bin/env python3
"""
Scaffold a new Neovim plugin with standard directory structure.

Usage:
    scaffold_plugin.py <plugin-name> --path <output-directory>

Example:
    scaffold_plugin.py my-plugin --path ~/projects/
"""

import argparse
import os
import sys
from pathlib import Path


def create_file(path: Path, content: str):
    """Create a file with the given content."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    print(f"  Created: {path}")


def scaffold_plugin(name: str, output_path: Path):
    """Create a new Neovim plugin scaffold."""
    plugin_path = output_path / name

    if plugin_path.exists():
        print(f"Error: Directory already exists: {plugin_path}")
        sys.exit(1)

    print(f"Creating plugin: {name}")
    print(f"Location: {plugin_path}\n")

    # lua/plugin-name/init.lua
    create_file(
        plugin_path / "lua" / name / "init.lua",
        f'''local M = {{}}

---@class {name.replace("-", "_").title()}Config
---@field enabled boolean Enable the plugin
M.config = {{
  enabled = true,
}}

--- Setup the plugin
---@param opts {name.replace("-", "_").title()}Config|nil
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {{}})

  if not M.config.enabled then
    return
  end

  -- Initialize plugin
  require("{name}.commands").setup()
  require("{name}.autocmds").setup()
end

return M
''',
    )

    # lua/plugin-name/config.lua
    create_file(
        plugin_path / "lua" / name / "config.lua",
        f'''local M = {{}}

---@type {name.replace("-", "_").title()}Config
M.defaults = {{
  enabled = true,
  -- Add default options here
}}

return M
''',
    )

    # lua/plugin-name/commands.lua
    create_file(
        plugin_path / "lua" / name / "commands.lua",
        f'''local M = {{}}

function M.setup()
  vim.api.nvim_create_user_command("{name.replace("-", "").title()}", function(opts)
    -- Command implementation
    vim.notify("{name}: Command executed", vim.log.levels.INFO)
  end, {{
    nargs = "*",
    desc = "{name} main command",
  }})
end

return M
''',
    )

    # lua/plugin-name/autocmds.lua
    create_file(
        plugin_path / "lua" / name / "autocmds.lua",
        f'''local M = {{}}

function M.setup()
  local group = vim.api.nvim_create_augroup("{name.replace("-", "_")}", {{ clear = true }})

  -- Example autocommand
  -- vim.api.nvim_create_autocmd("BufEnter", {{
  --   group = group,
  --   pattern = "*",
  --   callback = function(ev)
  --     -- Handle event
  --   end,
  -- }})
end

return M
''',
    )

    # lua/plugin-name/utils.lua
    create_file(
        plugin_path / "lua" / name / "utils.lua",
        '''local M = {}

--- Log a debug message
---@param msg string
function M.debug(msg)
  if vim.g.debug_mode then
    vim.notify(msg, vim.log.levels.DEBUG)
  end
end

--- Safe require with fallback
---@param module string
---@return any|nil
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    return nil
  end
  return result
end

return M
''',
    )

    # lua/plugin-name/health.lua
    create_file(
        plugin_path / "lua" / name / "health.lua",
        f'''local M = {{}}

function M.check()
  vim.health.start("{name}")

  -- Check Neovim version
  if vim.fn.has("nvim-0.9") == 1 then
    vim.health.ok("Neovim >= 0.9")
  else
    vim.health.error("Neovim >= 0.9 required")
  end

  -- Check dependencies
  local ok, _ = pcall(require, "plenary")
  if ok then
    vim.health.ok("plenary.nvim found")
  else
    vim.health.warn("plenary.nvim not found (optional)")
  end
end

return M
''',
    )

    # plugin/plugin-name.lua (optional lazy-load trigger)
    create_file(
        plugin_path / "plugin" / f"{name}.lua",
        f'''-- Optional: Trigger loading on VimEnter
-- Remove this file if using lazy.nvim with explicit triggers

if vim.g.loaded_{name.replace("-", "_")} then
  return
end
vim.g.loaded_{name.replace("-", "_")} = true

-- Defer setup to allow user configuration
vim.api.nvim_create_autocmd("User", {{
  pattern = "VeryLazy",
  callback = function()
    -- Only auto-setup if not already configured
    if not vim.g.{name.replace("-", "_")}_configured then
      require("{name}").setup()
    end
  end,
}})
''',
    )

    # doc/plugin-name.txt
    create_file(
        plugin_path / "doc" / f"{name}.txt",
        f'''*{name}.txt*  Description of {name}

==============================================================================
CONTENTS                                                    *{name}-contents*

    1. Introduction .......................... |{name}-introduction|
    2. Setup ................................. |{name}-setup|
    3. Commands .............................. |{name}-commands|
    4. Configuration ......................... |{name}-configuration|

==============================================================================
1. INTRODUCTION                                         *{name}-introduction*

{name} is a Neovim plugin that...

==============================================================================
2. SETUP                                                       *{name}-setup*

Using lazy.nvim: >lua
    {{
      "{name}",
      opts = {{}},
    }}
<

==============================================================================
3. COMMANDS                                                 *{name}-commands*

:{name.replace("-", "").title()}                                            *:{name.replace("-", "").title()}*
    Main command for {name}.

==============================================================================
4. CONFIGURATION                                       *{name}-configuration*

Default configuration: >lua
    require("{name}").setup({{
      enabled = true,
    }})
<

vim:tw=78:ts=8:ft=help:norl:
''',
    )

    # tests/plugin_spec.lua
    create_file(
        plugin_path / "tests" / "plugin_spec.lua",
        f'''describe("{name}", function()
  local plugin = require("{name}")

  before_each(function()
    -- Reset state before each test
  end)

  it("should have default config", function()
    assert.is_not_nil(plugin.config)
    assert.is_true(plugin.config.enabled)
  end)

  it("should merge user config", function()
    plugin.setup({{ enabled = false }})
    assert.is_false(plugin.config.enabled)
  end)
end)
''',
    )

    # tests/minimal_init.lua
    create_file(
        plugin_path / "tests" / "minimal_init.lua",
        f'''-- Minimal init for running tests
vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append("../plenary.nvim")

vim.cmd([[runtime plugin/plenary.vim]])
''',
    )

    # README.md
    create_file(
        plugin_path / "README.md",
        f'''# {name}

Description of {name}.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{{
  "{name}",
  opts = {{}},
}}
```

## Configuration

```lua
require("{name}").setup({{
  enabled = true,
}})
```

## Commands

- `:{name.replace("-", "").title()}` - Main command

## License

MIT
''',
    )

    # LICENSE
    create_file(
        plugin_path / "LICENSE",
        '''MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''',
    )

    # .gitignore
    create_file(
        plugin_path / ".gitignore",
        '''# Neovim
*.swp
*.swo
*~

# Luarocks
*.rock
lua_modules/

# Testing
.tests/
coverage/

# OS
.DS_Store
Thumbs.db
''',
    )

    # stylua.toml
    create_file(
        plugin_path / "stylua.toml",
        '''column_width = 100
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
''',
    )

    print(f"\n Plugin '{name}' created successfully!")
    print(f"\nNext steps:")
    print(f"  1. cd {plugin_path}")
    print(f"  2. Edit lua/{name}/init.lua to add your plugin logic")
    print(f"  3. Update doc/{name}.txt with documentation")
    print(f"  4. Run tests: nvim --headless -c \"PlenaryBustedDirectory tests/\"")


def main():
    parser = argparse.ArgumentParser(
        description="Scaffold a new Neovim plugin",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("name", help="Plugin name (e.g., my-plugin)")
    parser.add_argument(
        "--path",
        required=True,
        help="Output directory for the plugin",
    )

    args = parser.parse_args()

    # Validate plugin name
    if not args.name.replace("-", "").replace("_", "").isalnum():
        print("Error: Plugin name should only contain alphanumeric characters, hyphens, or underscores")
        sys.exit(1)

    output_path = Path(args.path).expanduser().resolve()

    if not output_path.exists():
        print(f"Creating output directory: {output_path}")
        output_path.mkdir(parents=True)

    scaffold_plugin(args.name, output_path)


if __name__ == "__main__":
    main()
