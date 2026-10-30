# Latency corpus

Workloads for measuring how Julia's execution strategy (for now: tiered execution, with
`--tiered=yes`) affects latency and throughput in realistic use. Local only: it collects
code from package documentation and is not meant for publishing as is.

## Layout

- `envs/<env>/` — one environment per package family, all in the separate depot `depot/`,
  so nothing touches `~/.julia`:
  - `base`: no packages, standard libraries only
  - `data`: DataFrames, CSV, PrettyTables, HTTP, JSON3 and documentation dependencies
  - `plots`: Plots (GR) with StatsPlots, RDatasets, …
  - `makie`: CairoMakie
  - `sciml`: ModelingToolkit, OrdinaryDiffEq, DifferentialEquations and friends
  - `bench`: BaseBenchmarks and BenchmarkTools
- `workloads/` — one file per workload, split into cells by `# %%` lines; each cell is one
  REPL input. Header lines: `# env:` (required), `# kind:` (`latency`, `throughput`,
  `mixed` or `unknown`), `# args:` (extra Julia options), `# source:` or `# about:`.
  - `docs/<package>/` — documentation pages turned into sessions by
    `runner/extract_docs.jl`, one page per workload, with cells that fail even without
    tiering pruned by `runner/prune.jl` (marked `# pruned`)
  - `gallery/` — the Plots example gallery (`runner/plots_gallery.jl`)
  - `sessions/` — hand-written interactive sessions (CSV, HTTP)
  - `scripts/` — hand-written ad-hoc scripts
  - `throughput/` — longer computations, where run time dominates compile time
  - `adversarial/` — cases aimed at particular parts of tiered execution
  - `excluded/` — documentation pages that lost too many cells to pruning
- `upstream/` — clones that documentation is extracted from, at the installed versions
- `runner/` — the harness (below)
- `results/<run>/results.tsv` and `results/<run>/logs/` — measurements

## Running

    julia runner/run.jl [--modes off,on] [--reps N] [--jobs N] [--timeout S] [--out DIR] paths...

Each run is a fresh process in an empty temporary directory, with the workload's
environment. `runner/cells.jl` evaluates the cells in `Main` with the REPL's soft scope,
shows each value as the REPL would (PNG for plots and figures, as an IDE or notebook
renders them) and records per cell: wall time, compile time on the main thread
(`Base.cumulative_compile_time_ns`), recompile time, bytes allocated, whether it threw, and
a hash of what was shown (to compare tiered and untiered output). A `process` row records
the whole process, startup and exit included. Use `--jobs 1` for timings; more jobs are
for checking that workloads run.

BaseBenchmarks, for steady-state throughput:

    julia --project=envs/bench [--tiered=yes] runner/basebench.jl out.json SECONDS group...
    julia --project=envs/bench runner/compare_bench.jl untiered.json tiered.json

## Sources

Documentation examples come from the documentation of DataFrames, PrettyTables,
ModelingToolkit (shipped with the packages), Makie (v0.24.16), Plots (v1.41.7) and
DiffEqDocs.jl; all are MIT licensed. The other workloads were written for this corpus.
