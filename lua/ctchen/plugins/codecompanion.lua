local copilot_model = "gpt-4.1"

local function copilot_model_fallback()
  return {
    [copilot_model] = {
      billing = {
        is_premium = true,
        multiplier = 1,
      },
      description = "GPT-4.1 (1x)",
      endpoint = "completions",
      formatted_name = "GPT-4.1",
      limits = {
        max_output_tokens = 16384,
        max_prompt_tokens = 128000,
      },
      opts = {
        can_stream = true,
        can_use_tools = true,
        has_vision = true,
      },
      vendor = "Azure OpenAI",
    },
  }
end

local function copilot_model_choices(self, opts)
  local fallback = copilot_model_fallback()

  if opts and opts.async == false then
    return fallback
  end

  local token = require("codecompanion.adapters.http.copilot.token")
  local fetched = token.fetch()
  local choices = {}

  if fetched and fetched.copilot_token then
    choices = require("codecompanion.adapters.http.copilot.get_models").choices(self, opts, fetched) or {}
  end

  if not choices[copilot_model] then
    choices = vim.tbl_deep_extend("force", choices, fallback)
  end

  return choices
end

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
      adapters = {
        http = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = copilot_model,
                  choices = copilot_model_choices,
                },
                top_p = {
                  condition = function(self)
                    local model = self.schema.model.default
                    if type(model) == "function" then
                      model = model()
                    end
                    return not vim.startswith(model, "o1")
                      and not model:find("codex")
                      and not vim.startswith(model, "gpt-5")
                  end,
                },
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = {
            name = "copilot",
            model = copilot_model,
          },
          send = {
            modes = { "n", "i" },
            key = "<C-s>",
          },
        },
        inline = {
          adapter = {
            name = "copilot",
            model = copilot_model,
          },
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
        },
      },
      -- 自定義 commit message prompt，使用英文
      prompt_library = {
        ["Generate PR"] = {
          strategy = "chat",
          description = "Generate commit message, branch name, and PR description",
          opts = {
            short_name = "pr",
            auto_submit = true,
          },
          prompts = {
            {
              role = "system",
              content = function()
                return string.format(
                  [[You are an expert at git workflows. Always respond in English only.
Today's date is: %s

Generate all three of the following based on the staged changes:

## 1. Commit Message
- Format: type(scope): description
- Types: feat, fix, docs, style, refactor, perf, test, chore
- Subject line under 50 characters
- Use imperative mood ("add" not "added")

## 2. Branch Name
- Format: type/yymmdd-short-description
- Types: feature, bugfix, hotfix, refactor, docs, test, chore
- Lowercase, hyphens only, 2-4 words in description

## 3. PR Description
- Title: concise PR title (under 70 chars)
- Summary: 2-3 bullet points describing what changed and why
- Test Plan: checklist of what should be tested

Output format (use exactly these headers):
### Commit Message
<commit message here>

### Branch Name
<branch name here>

### PR Description
**Title:** <pr title>

**Summary:**
<bullet points>

**Test Plan:**
<checklist>]],
                  os.date("%y%m%d")
                )
              end,
            },
            {
              role = "user",
              content = function()
                local diff = vim.fn.system("git diff --no-ext-diff --staged")
                if diff == "" then
                  return "No staged changes found. Please stage your changes first with `git add`."
                end
                return string.format(
                  [[Generate the commit message, branch name, and PR description for the following staged changes:

```diff
%s
```

Recent commits for reference:
```
%s
```

Recent branches for reference:
```
%s
```]],
                  diff,
                  vim.fn.system("git log --pretty=format:'%s' -n 10"),
                  vim.fn.system("git branch --sort=-committerdate --format='%(refname:short)' | head -10")
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
        ["Explain Code"] = {
          strategy = "chat",
          description = "Explain the selected code in detail",
          opts = {
            modes = { "v" },
            short_name = "explain",
            auto_submit = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert programmer and technical educator.
Explain code clearly and concisely, suitable for developers who want to understand the logic.

Format your response as:
1. **Summary** - One sentence overview of what the code does
2. **Step-by-Step Breakdown** - Explain each significant part
3. **Key Concepts** - Highlight any patterns, algorithms, or important concepts used
4. **Potential Improvements** - Brief suggestions if any (optional)]],
            },
            {
              role = "user",
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return string.format(
                  [[Please explain this %s code:

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
      {
        "<leader>ce",
        "<cmd>CodeCompanion /explain<cr>",
        mode = "v",
        desc = "Code Companion: Explain Selection",
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
