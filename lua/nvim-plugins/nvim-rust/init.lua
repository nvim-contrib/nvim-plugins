return {
	{
		"nvim-neotest/neotest",
		optional = true,
		opts = function(_, opts)
			if not opts.adapters then return opts end
			local has_coverage, coverage_config = pcall(require, "coverage.config")
			if not has_coverage then return opts end
			for _, adapter in ipairs(opts.adapters) do
				if adapter.name == "rustaceanvim" then
					local orig_build_spec = adapter.build_spec
					adapter.build_spec = function(args)
						local spec = orig_build_spec(args)
						if spec then
							spec.env = vim.tbl_extend("force", spec.env or {}, {
								RUSTFLAGS = "-C instrument-coverage",
								LLVM_PROFILE_FILE = "target/coverage-%m-%p.profraw",
							})
						end
						return spec
					end
					break
				end
			end
			return opts
		end,
	},
	{
		"andythigpen/nvim-coverage",
		opts = {
			lang = {
				rust = {
					coverage_command = "grcov ./target -s ${cwd} --binary-path ./target/debug/ -t coveralls --branch --ignore-not-existing --token NO_TOKEN",
					project_files_only = true,
					project_files = { "src/*", "tests/*" },
				},
			},
		},
	},
}
