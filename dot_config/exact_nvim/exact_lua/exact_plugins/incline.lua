return {
	{
		"b0o/incline.nvim",
		event = "VeryLazy",
		opts = {
			hide = {
				only_win = true,
			},
			ignore = {
				buftypes = {},
				filetypes = {},
				floating_wins = true,
				unlisted_buffers = false,
				wintypes = "special",
			},
			window = {
				margin = { horizontal = 0, vertical = 0 },
				padding = 1,
				placement = { horizontal = "right", vertical = "top" },
			},
			render = function(props)
				if not props.focused then
					return nil
				end

				local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				if name == "" then
					name = vim.bo[props.buf].filetype
				end
				if name == "" then
					name = vim.bo[props.buf].buftype
				end
				if name == "" then
					name = "window " .. vim.api.nvim_win_get_number(props.win)
				end

				local modified = vim.bo[props.buf].modified and " *" or ""

				return {
					" ",
					{ name .. modified, gui = "bold" },
					" ",
					guibg = "#7aa2f7",
					guifg = "#1a1b26",
				}
			end,
		},
	},
}
