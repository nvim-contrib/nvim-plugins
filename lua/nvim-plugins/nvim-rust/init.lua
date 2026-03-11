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

		--- Detect nightly toolchain without spawning a subprocess.
		--- Checks rust-toolchain.toml / rust-toolchain file, then RUSTUP_TOOLCHAIN env var.
		local function is_nightly_toolchain(cwd)
			for _, fname in ipairs({ "rust-toolchain.toml", "rust-toolchain" }) do
				local path = cwd .. "/" .. fname
				if vim.fn.filereadable(path) == 1 then
					for _, line in ipairs(vim.fn.readfile(path)) do
						if line:match("nightly") then return true end
					end
				end
			end
			local env = vim.fn.getenv("RUSTUP_TOOLCHAIN")
			return env ~= vim.NIL and tostring(env):match("nightly") ~= nil
		end

		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "rustaceanvim" then
				local build_spec_base = adapter.build_spec
				adapter.build_spec = function(args)
					local spec = build_spec_base(args)
					if spec then
						local cmd = spec.command
						if cmd[1] == "cargo" then
							local cwd = vim.fn.getcwd()
							local lcov_path = cwd .. "/target/lcov.info"
							local extra = { "llvm-cov", "--lcov" }
							if is_nightly_toolchain(cwd) then table.insert(extra, "--branch") end
							table.insert(extra, "--output-path")
							table.insert(extra, lcov_path)
							for j = #extra, 1, -1 do
								table.insert(cmd, 2, extra[j])
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
