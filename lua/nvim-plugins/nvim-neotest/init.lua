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
		local ginkgo_opts = core.plugin_opts("nvim-ginkgo")

		-- enable coverage flags when nvim-coverage is available
		local has_coverage = pcall(require, "coverage")
		if has_coverage then
			if not ginkgo_opts.command then
				ginkgo_opts.command = { "ginkgo", "run", "-v" }
			end
			table.insert(ginkgo_opts.command, "-cover")
			table.insert(ginkgo_opts.command, "-coverprofile=coverage.out")
		end

		table.insert(opts.adapters, adapter.setup(ginkgo_opts))
	end,
}
