return {
    "mfussenegger/nvim-lint",
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            python = { "mypy", "flake8" },
        }

        local lint_autogroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
            pattern = { "*.ts", "*.js" },
            group = lint_autogroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
