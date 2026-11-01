# Showcases

Cells where tiered execution turns a step that feels non-interactive into one that feels
quick: at least a second on master and at least four times faster tiered. Times are from the
second of two runs, when LLVM's output is in the object cache for both builds; the first run
of `results/full-4` was cold for both, and there tiering's lead is larger (ModelingToolkit
0.24 of master's time, against 0.63 warm). Package loading (`load` cells, and the `using`
part of a cell) is not something tiering can change; the code column shows the first line
after any `using`.

Run `results/full-4` (2026-10-31, tiering with its defaults: no JIT delay, no cost budget).
Regenerate with

    julia runner/showcases.jl --reps 2 results/<run> > table.md

| speedup | master s (slowest) | on s (slowest) | workload | cell | code |
|---:|---:|---:|---|---|---|
| 30.8× | 1.61 (1.6) | 0.05 (0.1) | dataframes/man_getting_started | 50 | `Tables.rowtable(df)` |
| 24.7× | 1.60 (1.6) | 0.06 (0.1) | dataframes/man_joins | 12 | `crossjoin(people, jobs, makeunique = true)` |
| 20.8× | 2.36 (2.4) | 0.11 (0.1) | diffeq/features_callback_functions | 41 | `callback = DE.ContinuousCallback(condition, affect!)` |
| 16.2× | 1.24 (1.2) | 0.08 (0.1) | diffeq/features_callback_functions | 3 | `sol = DE.solve(prob, DE.Tsit5(), callback = cb)` |
| 14.7× | 5.25 (5.3) | 0.36 (0.4) | diffeq/tutorials_sde_example | 17 | `function f!(du, u, p, t)` |
| 13.8× | 1.12 (1.1) | 0.08 (0.1) | diffeq/features_callback_functions | 36 | `sol = DE.solve(prob, DE.Vern8(), callback = cb, reltol = 1.0e-12, abstol = 1.0e-12)` |
| 13.5× | 1.46 (1.5) | 0.11 (0.1) | diffeq/solvers_nonautonomous_linear_ode | 1 | `_A = [2 -1; -3 -5] / 5` |
| 13.0× | 1.60 (1.6) | 0.12 (0.1) | makie/reference_blocks_polaraxis | 6 | `f = Figure(size = (800, 400))` |
| 9.9× | 1.30 (1.3) | 0.13 (0.1) | diffeq/features_callback_functions | 26 | `function dynamics!(du, u, p, t)` |
| 8.2× | 1.17 (1.2) | 0.14 (0.1) | makie/tutorials_inset_plot_tutorial | 8 | `border_rect = Rect2(50, min_price, 20, max_price - min_price)` |
| 8.0× | 2.33 (2.3) | 0.29 (0.3) | makie/reference_plots_tricontour | 4 | `Random.seed!(123)` |
| 7.5× | 8.95 (8.9) | 1.19 (1.2) | diffeq/examples_diffusion_implicit_heat_equation | 8 | `params = (; n)` |
| 7.4× | 1.17 (1.2) | 0.16 (0.2) | mtk/basics_inputoutput | 1 | `@variables x(t)=0 u(t)=0 y(t)` |
| 6.5× | 1.24 (1.2) | 0.19 (0.2) | makie/reference_plots_voronoiplot | 2 | `Random.seed!(1234)` |
| 6.5× | 1.87 (1.9) | 0.29 (0.3) | mtk/tutorials_nonlinear | 1 | `@variables x y z` |
| 6.3× | 10.43 (10.4) | 1.65 (1.6) | mtk/basics_validation | 6 | `struct NewType` |
| 6.2× | 1.59 (1.6) | 0.26 (0.3) | diffeq/examples_conditional_dosing | 4 | `sol = DE.solve(prob, DE.Tsit5(), tstops = [4.0], callback = cb)` |
| 5.4× | 5.78 (5.8) | 1.08 (1.1) | diffeq/tutorials_faster_ode_example | 17 | `de = MTK.complete(MTK.modelingtoolkitize(prob))` |
| 5.2× | 4.62 (4.6) | 0.89 (0.9) | makie/reference_plots_tooltip | 1 | `fig, ax, p = scatter(Point2f(0), marker = 'x', markersize = 20)` |
| 5.1× | 7.84 (7.8) | 1.53 (1.5) | mtk/tutorials_disturbance_modeling | 3 | `@named model = ModelWithInputs() # Model with load disturbance` |
| 5.1× | 3.04 (3.0) | 0.60 (0.6) | makie/reference_plots_arrows | 4 | `ps = Point2f.(1:5, 0)` |
| 5.1× | 1.82 (1.8) | 0.36 (0.4) | sessions/makie_quick | histogram | `hist(randn(rng, 2_000); bins = 40)` |
| 4.9× | 2.06 (2.1) | 0.42 (0.4) | plots/layouts | 7 | `gr(leg = false, bg = :lightgrey)` |
| 4.8× | 3.04 (3.0) | 0.64 (0.6) | makie/reference_plots_triplot | 2 | `n = 20` |
| 4.6× | 2.31 (2.3) | 0.50 (0.5) | makie/reference_plots_rainclouds | 2 | `rainclouds(category_labels, data_array;` |
| 4.6× | 13.08 (13.1) | 2.81 (2.8) | sessions/sciml_small_model | model | `@parameters k = 2.0 c = 0.3` |
| 4.5× | 1.73 (1.7) | 0.38 (0.4) | mtk/tutorials_modelingtoolkitize | 3 | `prob_jac = ODEProblem(sys, [], (0.0, 1e5), jac = true)` |
| 4.5× | 2.15 (2.2) | 0.48 (0.5) | makie/reference_plots_tricontourf | 4 | `Random.seed!(123)` |
| 4.4× | 13.19 (13.2) | 2.97 (3.0) | mtk/tutorials_stochastic_diffeq | 1 | `@parameters σ=10.0 ρ=2.33 β=26.0` |
| 4.4× | 9.93 (9.9) | 2.27 (2.3) | makie/reference_plots_voronoiplot | 1 | `Random.seed!(1234)` |
| 4.4× | 1.18 (1.2) | 0.27 (0.3) | plots/tutorial | 17 | `df = DataFrame(a=1:10, b=10*rand(10), c=10*rand(10))` |
| 4.3× | 2.29 (2.3) | 0.53 (0.5) | makie/reference_plots_qqplot | 1 | `xs = randn(100)` |
| 4.3× | 3.07 (3.1) | 0.72 (0.7) | makie/reference_plots_dendrogram | 2 | `leaves = Point2f[(1,0), (2,0.5), (3,1), (4,2), (5,0)]` |
| 4.3× | 17.87 (17.9) | 4.19 (4.2) | mtk/tutorials_linear_analysis | 1 | `@named P = FirstOrder(k = 1, T = 1) # A first-order system with pole in -1` |
| 4.3× | 5.07 (5.1) | 1.19 (1.2) | throughput/numerics_base | sparse solve | `n = 700` |
| 4.2× | 7.41 (7.4) | 1.77 (1.8) | mtk/examples_perturbation | 8 | `eq_pert = substitute_in_deriv(eq, x => x_series)` |
| 4.2× | 2.95 (2.9) | 0.70 (0.7) | mtk/basics_limiting | 1 | `function pnjlim(vnew, vold, vt, vcrit)` |
| 4.0× | 1.69 (1.7) | 0.42 (0.4) | diffeq/features_callback_functions | 13 | `const tstop = [5.0; 8.0]` |
