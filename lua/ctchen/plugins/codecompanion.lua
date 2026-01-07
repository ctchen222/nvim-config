return {
  {
    "olimorris/codecompanion.nvim",
    version = "v17.33.0",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    ft = { "codecompanion" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      opts = {
        language = "Traditional Chinese",
      },
      adapters = {},
      strategies = {
        chat = {
          send = {
            modes = { "n", "i" },
            key = "<C-s>",
          },
          model = "claude-sonnet-4-5-20250929",
        },
        inline = {
          adapter = "copilot",
          model = "claude-sonnet-4-5-20250929",
        },
      },
      inline = {
        adapter = "copilot",
        model = "claude-sonnet-4-5-20250929",
        keymaps = {
          accept_change = {
            modes = { n = "gda", v = "ga" },
            description = "Accept change (all in normal, selection in visual)",
          },
          reject_change = {
            modes = { n = "gdr", v = "gr" },
            opts = { nowait = true },
            description = "Reject change (all in normal, selection in visual)",
          },
        },
        show_keymaps = true,
      },
      -- 自定義 commit message prompt，使用英文
      prompt_library = {
        ["Commit Message"] = {
          strategy = "chat",
          description = "Generate a commit message (English)",
          opts = {
            short_name = "commit",
            auto_submit = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert at writing git commit messages following the Conventional Commit specification.
Always respond in English only, regardless of the user's language setting.

Rules:
- Use conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, perf, test, chore
- Keep the subject line under 50 characters
- Use imperative mood ("add" not "added")
- Output only the commit message without any explanations]],
            },
            {
              role = "user",
              content = function()
                local diff = vim.fn.system("git diff --no-ext-diff --staged")
                if diff == "" then
                  return "No staged changes found. Please stage your changes first with `git add`."
                end
                return string.format(
                  [[Generate a commit message for the following staged changes:

```diff
%s
```

Recent commit messages for reference:
```
%s
```]],
                  diff,
                  vim.fn.system("git log --pretty=format:'%s' -n 10")
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Branch Name"] = {
          strategy = "chat",
          description = "Generate a git branch name (English)",
          opts = {
            short_name = "branch",
            auto_submit = true,
          },
          prompts = {
            {
              role = "system",
              content = function()
                return string.format(
                  [[You are an expert at creating git branch names following best practices.
Always respond in English only, regardless of the user's language setting.

Rules:
- Use format: type/yymmdd-short-description
- Today's date is: %s
- Types: feature, bugfix, hotfix, refactor, docs, test, chore
- Use lowercase letters, numbers, and hyphens only
- Keep description concise (2-4 words separated by hyphens)
- No special characters or spaces
- Output only the branch name without any explanations or backticks

Example: feature/%s-add-user-auth]],
                  os.date("%y%m%d"),
                  os.date("%y%m%d")
                )
              end,
            },
            {
              role = "user",
              content = function()
                -- Check for staged or unstaged changes
                local staged = vim.fn.system("git diff --no-ext-diff --staged --stat")
                local unstaged = vim.fn.system("git diff --no-ext-diff --stat")
                local untracked = vim.fn.system("git ls-files --others --exclude-standard")

                local context = ""
                if staged ~= "" then
                  context = context .. "Staged changes:\n" .. staged .. "\n"
                end
                if unstaged ~= "" then
                  context = context .. "Unstaged changes:\n" .. unstaged .. "\n"
                end
                if untracked ~= "" then
                  context = context .. "New files:\n" .. untracked .. "\n"
                end

                if context == "" then
                  return "No changes detected. Please describe what you're working on:"
                end

                return string.format(
                  [[Generate a branch name based on these changes:

%s
Recent branch names for reference:
```
%s
```]],
                  context,
                  vim.fn.system("git branch --sort=-committerdate --format='%(refname:short)' | head -10")
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Optimize Code"] = {
          strategy = "chat",
          description = "Analyze and suggest optimizations for selected code",
          opts = {
            modes = { "v" },
            short_name = "optimize",
            auto_submit = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert code reviewer focused on performance and code quality.
Always respond in English.

When analyzing code, consider:
- Time and space complexity improvements
- Readability and maintainability
- Potential bugs or edge cases
- Language-specific best practices and idioms
- Unnecessary computations or redundant operations

Format your response as:
1. **Assessment** - Quick verdict: Is optimization needed? (Yes/No/Minor tweaks)
2. **Issues Found** - List specific problems (skip if none)
3. **Optimized Code** - Provide improved version with comments on changes
4. **Explanation** - Briefly explain the improvements and their impact]],
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return string.format(
                  [[Please analyze and optimize this %s code:

```%s
%s
```]],
                  context.filetype,
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>ca",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "Code Companion: Actions",
      },
      {
        "<leader>cc",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Code Companion: Chat",
      },
      {
        "<leader>ct",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = "n",
        desc = "Code Companion: Toggle Chat",
      },
      {
        "<leader>ct",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = "v",
        desc = "Code Companion: Add Selection to Chat",
      },
      {
        "<leader>ci",
        "<cmd>CodeCompanion<cr>",
        mode = { "n", "v" },
        desc = "Code Companion: Inline prompt",
      },
      {
        "<leader>co",
        "<cmd>CodeCompanion /optimize<cr>",
        mode = "v",
        desc = "Code Companion: Optimize Selection",
      },
    },
  },
  -- 移除 render-markdown.nvim，只保留 markview.nvim（功能更完整）
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "echasnovski/mini.diff",
    ft = { "codecompanion" },
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "codecompanion", "markdown" },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
