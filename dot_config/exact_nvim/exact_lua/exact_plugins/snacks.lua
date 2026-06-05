return {
	{
		"snacks.nvim",
		opts = {
			picker = {
				exclude = { "*.uid", "*.import" },
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
