# lazy.nvim Configuration Patterns

## Basic Setup

```lua
-- lua/config/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },           -- Import from lua/plugins/
    { import = "plugins.lang" },      -- Import from lua/plugins/lang/
  },
  defaults = {
    lazy = true,                      -- Lazy load by default
    version = false,                  -- Use latest commit
  },
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  checker = {
    enabled = true,                   -- Auto check for updates
    notify = false,                   -- Don't notify on updates
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

## Plugin Spec Properties

### Loading Triggers

```lua
{
  "plugin/name",

  -- Event-based loading
  event = "VeryLazy",                    -- After UI loads
  event = "BufReadPost",                 -- Single event
  event = { "BufReadPost", "BufNewFile" }, -- Multiple events
  event = "BufReadPost *.md",            -- Event with pattern

  -- Filetype-based loading
  ft = "lua",                            -- Single filetype
  ft = { "lua", "vim" },                 -- Multiple filetypes

  -- Command-based loading
  cmd = "Telescope",                     -- Single command
  cmd = { "Telescope", "TelescopeFind" }, -- Multiple commands

  -- Keymap-based loading
  keys = "<leader>ff",                   -- Simple keymap
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
    { "<leader>fs", mode = { "n", "v" }, desc = "Search" },  -- Multiple modes
  },

  -- Lazy loading disabled (load at startup)
  lazy = false,

  -- Load priority (higher = earlier, default = 50)
  priority = 1000,                       -- Use for colorschemes
}
```

### Configuration Options

```lua
{
  "plugin/name",

  -- Simple options (passed to setup())
  opts = {
    option1 = "value",
    option2 = true,
  },

  -- Function returning options
  opts = function()
    return {
      option = vim.fn.has("mac") == 1,
    }
  end,

  -- Custom config function
  config = function(_, opts)
    require("plugin").setup(opts)
    -- Additional setup
  end,

  -- Simple setup call (same as config = true)
  config = true,

  -- Init runs BEFORE plugin loads (at startup)
  init = function()
    vim.g.plugin_setting = "value"
  end,
}
```

### Dependencies

```lua
{
  "plugin/name",

  -- Simple dependencies
  dependencies = { "nvim-lua/plenary.nvim" },

  -- Dependencies with config
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
}
```

### Conditional Loading

```lua
{
  "plugin/name",

  -- Enable/disable statically
  enabled = true,
  enabled = false,
  enabled = vim.fn.has("nvim-0.10") == 1,

  -- Conditional loading (checked at runtime)
  cond = true,
  cond = function()
    return vim.fn.executable("git") == 1
  end,

  -- Note: enabled = false prevents install
  -- cond = false loads but doesn't setup
}
```

### Build/Install

```lua
{
  "plugin/name",

  -- Build command after install/update
  build = "make",
  build = ":TSUpdate",                   -- Neovim command
  build = function()
    require("plugin").build()
  end,

  -- Pin to specific version/tag/commit
  version = "1.0.0",
  version = "^1",                        -- SemVer range
  tag = "stable",
  commit = "abc123",
  branch = "main",

  -- Pin (don't update)
  pin = true,

  -- Dev mode (use local path)
  dev = true,
  dir = "~/projects/plugin",
}
```

## Common Patterns

### Colorscheme

```lua
{
  "folke/tokyonight.nvim",
  lazy = false,                          -- Load at startup
  priority = 1000,                       -- Load before other plugins
  config = function()
    require("tokyonight").setup({
      style = "night",
    })
    vim.cmd.colorscheme("tokyonight")
  end,
}
```

### LSP Configuration

```lua
{
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls" },
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup({})
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
      },
    })
  end,
}
```

### Completion

```lua
{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
```

### Treesitter

```lua
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
          },
        },
      },
    })
  end,
}
```

### Telescope

```lua
{
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
```

### UI Enhancement

```lua
-- Better vim.ui.select and vim.ui.input
{
  "stevearc/dressing.nvim",
  lazy = true,
  init = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require("lazy").load({ plugins = { "dressing.nvim" } })
      return vim.ui.select(...)
    end
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.input = function(...)
      require("lazy").load({ plugins = { "dressing.nvim" } })
      return vim.ui.input(...)
    end
  end,
}
```

### File Explorer

```lua
{
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- Open neo-tree if nvim is opened with a directory
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
      desc = "Start Neo-tree with directory",
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then
          return
        else
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end
      end,
    })
  end,
  opts = {
    filesystem = {
      follow_current_file = { enabled = true },
    },
  },
}
```

## Organization Patterns

### Split by Category

```
lua/plugins/
├── init.lua          -- Core plugins
├── editor.lua        -- Editor enhancements
├── ui.lua            -- UI plugins
├── lsp.lua           -- LSP configuration
├── completion.lua    -- Completion
├── treesitter.lua    -- Treesitter
└── lang/
    ├── lua.lua       -- Lua-specific
    ├── python.lua    -- Python-specific
    └── typescript.lua
```

### Module Return Pattern

```lua
-- lua/plugins/editor.lua
return {
  {
    "plugin1/name",
    -- config
  },
  {
    "plugin2/name",
    -- config
  },
}
```

### Importing

```lua
-- In lazy setup
require("lazy").setup({
  spec = {
    { import = "plugins" },           -- lua/plugins/*.lua
    { import = "plugins.lang" },      -- lua/plugins/lang/*.lua
  },
})
```

## Debugging

```lua
-- View lazy status
:Lazy

-- View plugin info
:Lazy info plugin-name

-- View load times
:Lazy profile

-- Check why plugin loaded
:Lazy debug

-- Reload plugin config
:Lazy reload plugin-name

-- Update all plugins
:Lazy update

-- Sync (install, clean, update)
:Lazy sync

-- Check health
:checkhealth lazy
```

## Performance Tips

1. **Use lazy loading triggers** - `event`, `cmd`, `keys`, `ft`
2. **Disable unused builtin plugins** in `performance.rtp.disabled_plugins`
3. **Use `VeryLazy` event** for non-critical plugins
4. **Profile startup** with `:Lazy profile`
5. **Defer heavy operations** with `vim.schedule` or `vim.defer_fn`
6. **Use `init` for settings**, `config` for setup
7. **Avoid `lazy = false`** unless necessary (colorschemes, core)
8. **Bundle related plugins** with dependencies to control load order
