---@type LazySpec
return {
	"nvim-neotest/neotest",
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			return {}
		end

		local has_coverage, _ = pcall(require, "coverage.config")
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
							local lcov_path = vim.fn.getcwd() .. "/target/lcov.info"
							local is_nightly = vim.fn.system("rustup show active-toolchain 2>/dev/null"):match("nightly") ~= nil
							local i = 2
							table.insert(cmd, i, "llvm-cov") ; i = i + 1
							table.insert(cmd, i, "--lcov")   ; i = i + 1
							if is_nightly then
								table.insert(cmd, i, "--branch") ; i = i + 1
							end
							table.insert(cmd, i, "--output-path") ; i = i + 1
							table.insert(cmd, i, lcov_path)
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
