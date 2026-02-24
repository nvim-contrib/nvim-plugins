---@type LazySpec
return {
	"nvim-neotest/neotest",
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			return {}
		end

		local has_coverage, coverage_config = pcall(require, "coverage.config")
		if not has_coverage then
			return opts
		end

		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "rustaceanvim" then
				local build_spec_base = adapter.build_spec
				adapter.build_spec = function(args)
					local spec = build_spec_base(args)
					if spec then
						local cmd = spec.command
						if cmd[1] == "cargo" then
							local coverage_file = vim.tbl_get(coverage_config.opts, "lang", "rust", "coverage_file")
									or "lcov.info"
							local lcov_path = vim.fn.getcwd() .. "/" .. coverage_file

							table.insert(cmd, 2, "llvm-cov")
							table.insert(cmd, 3, "--lcov")
							table.insert(cmd, 4, "--output-path")
							table.insert(cmd, 5, lcov_path)
						end
					end
					return spec
				end
				break
			end
		end
		return opts
	end,
}
