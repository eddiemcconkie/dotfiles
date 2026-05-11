return {
    "folke/sidekick.nvim",
    keys = {
        {
            "<leader>as",
            function() require("sidekick.cli").select({ filter = { installed = true } }) end,
            desc = "Select session",
        },
    },
    opts = {
        cli = {
            mux = {
                enabled = false, -- Enabling tmux persists sessions, but changes the bg color
                backend = "tmux",
            },
        },
        copilot = {
            status = {
                enabled = false,
            },
        },
    },
}
