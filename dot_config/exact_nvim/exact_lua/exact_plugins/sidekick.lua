return {
    "folke/sidekick.nvim",
    keys = {
        {
            "<leader>as",
            function() require("sidekick.cli").select({filter={external=true}}) end,
            desc = "Select session",
        },
    },
    opts = {
        cli = {
            mux = {
                enabled = true,
                backend = "tmux",
            },
        },
        copilot = {
            status = {
                level = vim.log.levels.OFF,
            },
        },
    },
}
