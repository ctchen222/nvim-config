return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  dependencies = {
    "mfussenegger/nvim-dap",
    "williamboman/mason.nvim",
  },
  config = function()
    local jdtls = require("jdtls")
    local mason_registry = require("mason-registry")

    -- =====================
    -- 路徑設定
    -- =====================
    local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
    local java_debug_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
    local java_test_path = mason_registry.get_package("java-test"):get_install_path()

    -- 根據作業系統選擇設定
    local config_path
    if vim.fn.has("mac") == 1 then
      config_path = jdtls_path .. "/config_mac"
    elseif vim.fn.has("unix") == 1 then
      config_path = jdtls_path .. "/config_linux"
    else
      config_path = jdtls_path .. "/config_win"
    end

    local lombok_path = jdtls_path .. "/lombok.jar"
    local jar_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    -- 專案名稱（用於 workspace）
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    -- =====================
    -- Debug bundles
    -- =====================
    local bundles = {}

    -- java-debug-adapter
    local java_debug_bundle = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
    if java_debug_bundle ~= "" then
      table.insert(bundles, java_debug_bundle)
    end

    -- java-test
    local java_test_bundles = vim.fn.glob(java_test_path .. "/extension/server/*.jar", true, true)
    for _, bundle in ipairs(java_test_bundles) do
      if not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar") then
        table.insert(bundles, bundle)
      end
    end

    -- =====================
    -- Capabilities (for nvim-cmp)
    -- =====================
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- =====================
    -- 設定 autocmd 在開啟 Java 檔案時啟動 JDTLS
    -- =====================
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok_path,
            "-jar", jar_path,
            "-configuration", config_path,
            "-data", workspace_dir,
          },

          root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

          capabilities = capabilities,

          settings = {
            java = {
              -- Eclipse 下載來源
              eclipse = {
                downloadSources = true,
              },
              -- Maven 設定
              maven = {
                downloadSources = true,
              },
              -- 程式碼建議
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              -- 格式化
              format = {
                enabled = true,
                settings = {
                  -- 可以在這裡指定 eclipse formatter 設定檔
                  -- url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                  -- profile = "GoogleStyle",
                },
              },
              -- 自動完成
              completion = {
                favoriteStaticMembers = {
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.Assert.*",
                  "org.mockito.Mockito.*",
                  "java.util.Objects.requireNonNull",
                  "java.util.Objects.requireNonNullElse",
                },
                importOrder = {
                  "java",
                  "javax",
                  "org",
                  "com",
                },
              },
              -- 內容輔助
              contentProvider = {
                preferred = "fernflower",
              },
              -- 程式碼產生
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              -- 程式碼風格
              codeGeneration = {
                toString = {
                  template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                useBlocks = true,
                hashCodeEquals = {
                  useJava7Objects = true,
                },
              },
              -- 專案設定
              configuration = {
                updateBuildConfiguration = "interactive",
                -- 可以在這裡指定 JDK 位置
                -- runtimes = {
                --   {
                --     name = "JavaSE-17",
                --     path = "/path/to/jdk-17",
                --   },
                --   {
                --     name = "JavaSE-21",
                --     path = "/path/to/jdk-21",
                --   },
                -- },
              },
            },
            signatureHelp = {
              enabled = true,
            },
          },

          -- Debug 支援
          init_options = {
            bundles = bundles,
          },

          on_attach = function(client, bufnr)
            -- 標準 LSP 快捷鍵
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", { buffer = bufnr, desc = "Show LSP references" })
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
            vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { buffer = bufnr, desc = "Show LSP definitions" })
            vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { buffer = bufnr, desc = "Show LSP implementations" })
            vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { buffer = bufnr, desc = "Show LSP type definitions" })
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "See available code actions" })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Smart rename" })
            vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { buffer = bufnr, desc = "Show buffer diagnostics" })
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show line diagnostics" })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Go to previous diagnostic" })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Go to next diagnostic" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Show documentation" })
            vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", { buffer = bufnr, desc = "Restart LSP" })

            -- Java 專用快捷鍵
            vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { buffer = bufnr, desc = "Java: Organize imports" })
            vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, { buffer = bufnr, desc = "Java: Extract variable" })
            vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, { buffer = bufnr, desc = "Java: Extract variable" })
            vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, { buffer = bufnr, desc = "Java: Extract constant" })
            vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, { buffer = bufnr, desc = "Java: Extract constant" })
            vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, { buffer = bufnr, desc = "Java: Extract method" })

            -- Debug 快捷鍵
            vim.keymap.set("n", "<leader>jt", jdtls.test_nearest_method, { buffer = bufnr, desc = "Java: Test nearest method" })
            vim.keymap.set("n", "<leader>jT", jdtls.test_class, { buffer = bufnr, desc = "Java: Test class" })

            -- 設定 DAP
            jdtls.setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
          end,
        }

        jdtls.start_or_attach(config)
      end,
    })
  end,
}
