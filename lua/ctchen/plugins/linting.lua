return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local eslint_filetypes = {
      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true,
      svelte = true,
      vue = true,
    }

    local eslint_config_files = {
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.json",
      ".eslintrc.yaml",
      ".eslintrc.yml",
    }

    local function find_eslint_root(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.uv.cwd()
      return vim.fs.find(eslint_config_files, { path = start, upward = true })[1]
    end

    lint.linters_by_ft = {
      python = { "ruff" },
      markdown = { "vale" },
      sql = { "sqlfluff" },
    }

    lint.linters.ruff.args = vim.list_extend(vim.deepcopy(lint.linters.ruff.args), { "--line-length", "120" })

    lint.linters.sqlfluff.args = {
      "lint",
      "--format=json",
      "--dialect",
      "postgres",
      "-",
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    local function try_lint(bufnr, event)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) or bufnr ~= vim.api.nvim_get_current_buf() then
        return
      end

      local ft = vim.bo[bufnr].filetype
      if eslint_filetypes[ft] then
        if event == "InsertLeave" then
          return
        end

        local config_path = find_eslint_root(bufnr)
        if not config_path then
          return
        end

        lint.try_lint("eslint", {
          cwd = vim.fs.dirname(config_path),
        })
        return
      end

      lint.try_lint()
    end

    -- 移除 BufEnter 以提升效能，只在儲存和離開 insert mode 時 lint
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function(args)
        -- 延遲執行以避免阻塞
        vim.defer_fn(function()
          try_lint(args.buf, args.event)
        end, 100)
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
