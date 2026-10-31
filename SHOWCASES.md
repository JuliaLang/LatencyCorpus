# Showcases

Cells where tiered execution turns a step that feels non-interactive into one that feels
quick: at least a second on master and at least four times faster tiered. Times are the
mean of three runs, with the slowest in parentheses: the first run in a fresh depot is often
much slower on master. Package loading (`load` cells, and the `using` part of a cell) is not
something tiering can change; the code column shows the first line after any `using`.

Run `results/full-2` (2026-10-30, before the global random number generator was seeded and
before `@fastmath`/`muladd` code was compiled). Regenerate with

    julia runner/showcases.jl results/<run> > table.md

| speedup | master s (slowest) | on s (slowest) | workload | cell | code |
|---:|---:|---:|---|---|---|
| 67.6× | 1.64 (1.7) | 0.02 (0.0) | dataframes/man_getting_started | 50 | `Tables.rowtable(df)` |
| 21.7× | 3.54 (5.7) | 0.16 (0.2) | diffeq/features_callback_functions | 41 | `callback = DE.ContinuousCallback(condition, affect!)` |
| 21.6× | 2.19 (5.2) | 0.10 (0.2) | mtk/tutorials_linear_analysis | 3 | `P = tf(1.0, [1, 1]) \|> ss` |
| 17.5× | 1.72 (1.8) | 0.10 (0.2) | dataframes/man_joins | 12 | `crossjoin(people, jobs, makeunique = true)` |
| 14.7× | 1.40 (1.7) | 0.09 (0.1) | diffeq/features_callback_functions | 3 | `sol = DE.solve(prob, DE.Tsit5(), callback = cb)` |
| 11.7× | 1.78 (2.1) | 0.15 (0.2) | makie/reference_blocks_polaraxis | 6 | `f = Figure(size = (800, 400))` |
| 11.2× | 1.45 (2.1) | 0.13 (0.2) | diffeq/features_callback_functions | 36 | `sol = DE.solve(prob, DE.Vern8(), callback = cb, reltol = 1.0e-12, abstol = 1.0e-12)` |
| 10.1× | 17.27 (31.1) | 1.70 (1.8) | mtk/basics_validation | 6 | `struct NewType` |
| 9.8× | 2.43 (4.7) | 0.25 (0.3) | makie/reference_plots_voronoiplot | 2 | `Random.seed!(1234)` |
| 9.2× | 1.22 (1.8) | 0.13 (0.1) | mtk/tutorials_domain_connections | 4 | `@component function HydraulicSystem(; name)` |
| 8.8× | 2.02 (3.2) | 0.23 (0.4) | diffeq/features_callback_functions | 26 | `function dynamics!(du, u, p, t)` |
| 8.0× | 2.02 (2.8) | 0.25 (0.4) | diffeq/examples_conditional_dosing | 4 | `sol = DE.solve(prob, DE.Tsit5(), tstops = [4.0], callback = cb)` |
| 7.8× | 1.21 (1.3) | 0.16 (0.2) | makie/tutorials_inset_plot_tutorial | 8 | `border_rect = Rect2(50, min_price, 20, max_price - min_price)` |
| 6.9× | 4.92 (8.6) | 0.71 (0.7) | makie/reference_plots_triplot | 2 | `n = 20` |
| 6.8× | 17.98 (32.0) | 2.63 (2.8) | mtk/tutorials_ode_modeling | 2 | `@parameters τ = 3.0 # parameters and their values` |
| 6.2× | 1.22 (2.7) | 0.20 (0.4) | sessions/csv_analysis | join | `stores = DataFrame(store=["S$i" for i in 1:12], region=repeat(["north", "south", "east"], 4))` |
| 5.3× | 1.66 (2.3) | 0.31 (0.4) | makie/explanations_faq | 4 | `resize_to_layout!(f)` |
| 5.2× | 3.40 (5.5) | 0.65 (0.9) | makie/reference_plots_tricontour | 4 | `Random.seed!(123)` |
| 5.1× | 2.30 (2.5) | 0.45 (0.5) | makie/reference_plots_tricontourf | 4 | `Random.seed!(123)` |
| 4.9× | 1.93 (2.4) | 0.39 (0.4) | mtk/tutorials_modelingtoolkitize | 3 | `prob_jac = ODEProblem(sys, [], (0.0, 1e5), jac = true)` |
| 4.9× | 5.59 (6.9) | 1.14 (1.2) | makie/reference_plots_tooltip | 1 | `fig, ax, p = scatter(Point2f(0), marker = 'x', markersize = 20)` |
| 4.9× | 5.72 (6.6) | 1.18 (2.6) | diffeq/tutorials_sde_example | 17 | `function f!(du, u, p, t)` |
| 4.6× | 10.38 (14.3) | 2.26 (2.5) | mtk/tutorials_disturbance_modeling | 3 | `@named model = ModelWithInputs() # Model with load disturbance` |
| 4.6× | 2.64 (3.0) | 0.57 (0.7) | makie/reference_plots_rainclouds | 2 | `rainclouds(category_labels, data_array;` |
| 4.6× | 3.76 (5.3) | 0.82 (1.3) | makie/reference_plots_arrows | 4 | `ps = Point2f.(1:5, 0)` |
| 4.5× | 13.31 (19.8) | 2.94 (3.8) | makie/reference_plots_voronoiplot | 1 | `Random.seed!(1234)` |
| 4.5× | 3.06 (5.4) | 0.68 (0.7) | mtk/api_variables | 38 | `using DynamicQuantities;` |
| 4.4× | 2.52 (2.7) | 0.57 (0.6) | makie/reference_plots_qqplot | 1 | `xs = randn(100)` |
| 4.3× | 2.00 (2.9) | 0.46 (0.7) | diffeq/examples_kepler_problem | 8 | `function first_integrals_manifold(residual, u, p, t)` |
| 4.3× | 2.28 (3.4) | 0.53 (0.8) | diffeq/features_callback_functions | 13 | `const tstop = [5.0; 8.0]` |
| 4.2× | 8.00 (12.3) | 1.90 (3.2) | mtk/basics_limiting | 2 | `@variables v(t) = 0.0` |
| 4.2× | 31.88 (54.5) | 7.60 (9.9) | mtk/tutorials_linear_analysis | 1 | `@named P = FirstOrder(k = 1, T = 1) # A first-order system with pole in -1` |
| 4.2× | 3.69 (4.9) | 0.88 (1.2) | makie/reference_plots_dendrogram | 2 | `leaves = Point2f[(1,0), (2,0.5), (3,1), (4,2), (5,0)]` |
| 4.2× | 1.78 (3.3) | 0.43 (0.7) | mtk/tutorials_initialization | 41 | `prob2 = remake(prob; u0 = [y => 0.0, D(x) => 0.0, x => nothing, D(y) => nothing]);` |
