return {
	{
		"snacks.nvim",
		opts = {
			picker = {
				exclude = { "*.uid", "*.import", "addons/**/*" },
				sources = {
					explorer = {
						hidden = true,
						ignored = true,
						exclude = { "*.uid", "*.import" },
					},
				},
			},
			scroll = {
				enabled = false,
			},
		},
	},
}
