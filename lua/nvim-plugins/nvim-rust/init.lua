---@type LazySpec
return {
	"nvim-neotest/neotest",
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			return opts
		end
		local has_coverage = pcall(require, "coverage.config")
		if not has_coverage then
			return opts
		end
		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "rustaceanvim" then
				local orig_build_spec = adapter.build_spec
				adapter.build_spec = function(args)
					local spec = orig_build_spec(args)
					if spec then
						local cmd = spec.command
						if cmd[1] == "cargo" and cmd[2] == "test" then
							local rust_config = require("coverage.config").opts.lang.rust
							local lcov_path = vim.fn.getcwd() .. "/" .. rust_config.coverage_file
							local is_doctest = false
							for _, arg in ipairs(cmd) do
								if arg == "--doc" then
									is_doctest = true
									break
								end
							end
							-- cargo test [...] -> cargo llvm-cov [nextest] --lcov --output-path target/lcov.info [...]
							table.insert(cmd, 2, "llvm-cov")
							if is_doctest then
								table.insert(cmd, 4, "--lcov")
								table.insert(cmd, 5, "--output-path")
								table.insert(cmd, 6, lcov_path)
							else
								cmd[3] = "nextest"
								table.insert(cmd, 4, "--lcov")
								table.insert(cmd, 5, "--output-path")
								table.insert(cmd, 6, lcov_path)
							end
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
