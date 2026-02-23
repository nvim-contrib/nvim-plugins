return {
	"andythigpen/nvim-coverage",
	opts = {
		lang = {
			rust = {
				coverage_command = "grcov ${cwd} -s ${cwd} --binary-path ./target/debug/ -t coveralls --branch --ignore-not-existing --token NO_TOKEN",
				project_files_only = true,
				project_files = { "src/*", "tests/*" },
			},
		},
	},
}
