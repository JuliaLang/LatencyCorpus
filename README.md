# Latency corpus

Workloads for measuring how changes to the way Julia compiles and runs code (so far:
tiered execution, with `--tiered=yes`) affect latency and throughput in realistic use: REPL
sessions worked through from package documentation, hand-written sessions and scripts, and
longer computations.

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
  REPL input. Header lines: `# env:` (required), `# kind:` (`interactive`, `overcompile` or
  `throughput`: the class the workload is judged as, see `runner/summarize.jl`), `# throughput: <cell>`
  (a compute-bound cell in a workload of another class), `# mode: script` (an end-to-end script,
  judged only by its process's wall time; other workloads are REPL sessions), `# args:` (extra
  Julia options), `# source:` or `# about:`.
  - `docs/<package>/` — documentation pages turned into sessions by
    `runner/extract_docs.jl`, one page per workload, with cells that fail even without
    tiering pruned by `runner/prune.jl` (marked `# pruned`)
  - `gallery/` — the Plots example gallery (`runner/plots_gallery.jl`)
  - `sessions/` — hand-written interactive sessions (CSV, HTTP)
  - `scripts/` — hand-written ad-hoc scripts
  - `throughput/` — longer computations, where run time dominates compile time
  - `adversarial/` — cases aimed at particular parts of tiered execution
  - `excluded/` — documentation pages that lost too many cells to pruning
- `runner/` — the harness (below)

Made locally and not part of the repository: `depot/` (installed and precompiled
packages), `results/<run>/` (measurements: `results.tsv` and `logs/`), `logs/` and
`upstream/` (clones of the documentation sources, for extracting workloads again).

## Setup

    runner/install.sh <julia>

installs every environment from its manifest into `depot/` and precompiles it with the
given Julia. Precompiled packages are specific to a Julia build, so run it with each build
before measuring it.

## Running

    julia runner/run.jl [--julia PATH] [--master PATH] [--modes off,on] [--reps N] [--jobs N]
                        [--timeout S] [--think S] [--out DIR] paths...

`--julia` is the build under test and `--master` the baseline build, run by the `master`
mode, which comparisons should be against; the modes are defined at the top of
`runner/run.jl`. Each workload gets an object cache of its own in each mode, empty before
its first repetition: the first repetition is cold, as a first session is, and later ones
are warm with only what that workload compiled before, as when a session is repeated. No
cache is shared between workloads, so results do not depend on the order runs happen in.

`--think S` pauses S seconds between the cells of a session, as a user reading and typing would,
outside every cell's time; scripts run straight through.

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

## Sources and licenses

The workloads under `workloads/docs/`, `workloads/excluded/` and `workloads/gallery/` are
taken from the documentation of DataFrames.jl, PrettyTables.jl, ModelingToolkit.jl,
DiffEqDocs.jl, Makie.jl and Plots.jl, all under the MIT license. Each such workload names, in
its `# source:` header line, the page it was taken from at the version it was taken from,
and in its `# license:` line the license that page is under, which applies to that workload.
Everything else here, the harness and the other workloads, is under the MIT license in
[LICENSE](LICENSE).
