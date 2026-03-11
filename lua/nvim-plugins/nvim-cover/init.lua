---@type LazySpec
return {
	"nvim-contrib/nvim-coverage",
	event = "User AstroFile",
	opts = {
		auto_reload = { enabled = true },
	},
	dependencies = {
		{
			"nvim-neotest/neotest",
			optional = true,
			opts = function(_, opts)
				opts.consumers = opts.consumers or {}
				-- After Go tests finish, convert coverage.out → coverage/lcov.info
				opts.consumers.coverage_go = function(client)
					client.listeners.results = function(_, results, partial)
						if partial then return end
						for _, result in pairs(results) do
							if result.output then
								local cwd = vim.fn.getcwd()
								local coverprofile = cwd .. "/coverage.out"
								local lcov_out = cwd .. "/coverage/lcov.info"
								if vim.fn.filereadable(coverprofile) == 1 then
									vim.fn.mkdir(cwd .. "/coverage", "p")
									vim.fn.jobstart({
										"go", "tool", "cover",
										"-o", lcov_out,
										coverprofile,
									}, {
										on_exit = function(_, code)
											if code == 0 then
												vim.schedule(function()
													require("coverage").load(lcov_out, require("coverage.signs").is_enabled())
												end)
											end
										end,
									})
									return
								end
							end
						end
					end
					return {}
				end
			end,
		},
		"nvim-lua/plenary.nvim",
		{
			"AstroNvim/astroui",
			opts = {
				icons = {
					Tests = "󰗇",
					Coverage = "",
				},
			},
		},
		{
			"AstroNvim/astrocore",
			optional = true,
			opts = function(_, opts)
				local astroui = require("astroui")
				local maps = opts.mappings

				local tests_prefix = "<Leader>T"
				local coverage_prefix = tests_prefix .. "C"

				-- INFO: Compatibility with `neotest` and `vim-test`
				maps.n[tests_prefix] = { desc = astroui.get_icon("Tests", 1, true) .. "Tests" }

				maps.n[coverage_prefix] = { desc = astroui.get_icon("Coverage", 1, true) .. "Coverage" }
				maps.n[coverage_prefix .. "t"] = {
					function()
						require("coverage").toggle()
					end,
					desc = "Toggle coverage",
				}
				maps.n[coverage_prefix .. "s"] = {
					function()
						require("coverage").summary()
					end,
					desc = "Show coverage summary",
				}
				maps.n[coverage_prefix .. "c"] = {
					function()
						require("coverage").clear()
					end,
					desc = "Clear coverage",
				}
				maps.n[coverage_prefix .. "l"] = {
					function()
						require("coverage").load(nil, true)
					end,
					desc = "Load and show coverage",
				}
				maps.n[coverage_prefix .. "h"] = {
					function()
						require("coverage").toggle_line_hits()
					end,
					desc = "Toggle line hits",
				}
				maps.n[coverage_prefix .. "b"] = {
					function()
						require("coverage").toggle_branch_hits()
					end,
					desc = "Toggle branch hits",
				}

				-- Sign navigation (] / [ convention)
				maps.n["]Cu"] = {
					function()
						require("coverage").jump_next("uncovered")
					end,
					desc = "Next uncovered line",
				}
				maps.n["[Cu"] = {
					function()
						require("coverage").jump_prev("uncovered")
					end,
					desc = "Prev uncovered line",
				}
				maps.n["]Cc"] = {
					function()
						require("coverage").jump_next("covered")
					end,
					desc = "Next covered line",
				}
				maps.n["[Cc"] = {
					function()
						require("coverage").jump_prev("covered")
					end,
					desc = "Prev covered line",
				}
				maps.n["]Cp"] = {
					function()
						require("coverage").jump_next("partial")
					end,
					desc = "Next partial line",
				}
				maps.n["[Cp"] = {
					function()
						require("coverage").jump_prev("partial")
					end,
					desc = "Prev partial line",
				}
			end,
		},
	},
}
