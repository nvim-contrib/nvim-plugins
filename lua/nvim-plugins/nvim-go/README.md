# nvim-go

Configures Go testing in Neovim using [neotest](https://github.com/nvim-neotest/neotest) with [nvim-ginkgo](https://github.com/nvim-contrib/nvim-ginkgo) as the Ginkgo adapter.

## Behaviour

- Depends on `nvim-contrib/nvim-ginkgo` (always installed).
- When a `neotest-golang` or `neotest-go` adapter is present, patches its
  `filter_dir` to skip directories that contain a Ginkgo suite file:
  - `suite_test.go`
  - `<dirname>_suite_test.go`

  This prevents the Go adapter from picking up Ginkgo-managed packages, leaving
  them exclusively to the Ginkgo adapter.
- Registers the Ginkgo adapter via `nvim-ginkgo`.
- When [nvim-coverage](https://github.com/andythigpen/nvim-coverage) is
  available, appends `-cover -coverprofile=<coverage_file>` to the Ginkgo
  run command automatically.
