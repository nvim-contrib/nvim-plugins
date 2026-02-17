return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"nvim-contrib/nvim-snippet",
	},
	config = function(plugin, opts)
		-- include the default astronvim config that calls the setup call
		local setup = require("astronvim.plugins.configs.luasnip")
		-- setup the plugin
		setup(plugin, opts)

		local loader = require("luasnip.loaders.from_vscode")
		-- load snippets paths
		loader.lazy_load({
			paths = { vim.fn.stdpath("data") .. "/lazy/nvim-snippet" },
		})
	end,
}
