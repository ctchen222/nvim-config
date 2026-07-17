local ensure_installed = {
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "prisma",
  "markdown",
  "markdown_inline",
  "svelte",
  "graphql",
  "bash",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
  "query",
  "vimdoc",
  "c",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "python",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.setup()
    vim.treesitter.language.register("gotmpl", "helm")

    local installed = treesitter.get_installed("parsers")
    local missing = vim.tbl_filter(function(parser)
      return not vim.list_contains(installed, parser)
    end, ensure_installed)
    if #missing > 0 then
      treesitter.install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local language = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if language and vim.list_contains(ensure_installed, language) then
          vim.treesitter.start(args.buf, language)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.keymap.set({ "n", "x" }, "<C-space>", function()
      vim.treesitter.select("parent")
    end, { desc = "Select parent Tree-sitter node" })
    vim.keymap.set("x", "<bs>", function()
      vim.treesitter.select("child")
    end, { desc = "Select child Tree-sitter node" })

    require("nvim-ts-autotag").setup()
  end,
}
