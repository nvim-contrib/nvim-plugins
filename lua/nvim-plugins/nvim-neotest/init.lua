return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-contrib/nvim-ginkgo",
	},
	opts = function(_, opts)
		if not opts.adapters then
			opts.adapters = {}
		end

		for index = #opts.adapters, 1, -1 do
			local adapter = opts.adapters[index]
			-- we should replace the adapter
			if adapter.name == "neotest-golang" or adapter.name == "neotest-go" then
				-- remove the adapter
				table.remove(opts.adapters, index)
			end
		end

		local core = require("astrocore")
		local adapter = require("nvim-ginkgo")
		-- setups the core
		table.insert(opts.adapters, adapter.setup(core.plugin_opts("nvim-ginkgo")))
	end,
}
