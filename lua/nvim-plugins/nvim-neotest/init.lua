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
		local ginkgo_opts = core.plugin_opts("nvim-ginkgo")
		local ginkgo_adapter = require("nvim-ginkgo")

		-- enable coverage flags when nvim-coverage is available
		local has_coverage, coverage_config = pcall(require, "coverage.config")
		if has_coverage then
			if not ginkgo_opts.command then
				ginkgo_opts.command = { "ginkgo", "run", "-v" }
			end
			local go_coverage_file = coverage_config.lang.go.coverage_file
			table.insert(ginkgo_opts.command, "-cover")
			table.insert(ginkgo_opts.command, "-coverprofile=" .. go_coverage_file)
		end

		table.insert(opts.adapters, ginkgo_adapter.setup(ginkgo_opts))
	end,
}
