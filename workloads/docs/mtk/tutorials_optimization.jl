# env: sciml
# kind: unknown
# source: tutorials/optimization.md

# %% 1
using ModelingToolkit, Optimization
using OptimizationOptimJL: Optim
@variables begin
    x = 1.0, [bounds = (-2.0, 2.0)]
    y = 3.0, [bounds = (-1.0, 3.0)]
end
@parameters a=1.0 b=1.0
rosenbrock = (a - x)^2 + b * (y - x^2)^2
@mtkcompile sys = OptimizationSystem(rosenbrock, [x, y], [a, b])

# %% 2
u0 = [y => 2.0]
p = [b => 100.0]

prob = OptimizationProblem(sys, vcat(u0, p), grad = true, hess = true)
u_opt = solve(prob, Optim.GradientDescent())

# %% 3
using Plots
x_plot = -2:0.01:2
y_plot = -1:0.01:3
contour(
    x_plot, y_plot, (x, y) -> (1 - x)^2 + 100 * (y - x^2)^2, fill = true, color = :viridis,
    ratio = :equal, xlims = (-2, 2))
scatter!([u_opt[1]], [u_opt[2]], ms = 10, label = "minimum")

# %% 4
using ModelingToolkit, Optimization
using OptimizationOptimJL: Optim

@variables begin
    x = 0.14, [bounds = (-2.0, 2.0)]
    y = 0.14, [bounds = (-1.0, 3.0)]
end
@parameters a=1.0 b=100.0
rosenbrock = (a - x)^2 + b * (y - x^2)^2
cons = [
    x^2 + y^2 ≲ 1
]
@mtkcompile sys = OptimizationSystem(rosenbrock, [x, y], [a, b], constraints = cons)
prob = OptimizationProblem(sys, [], grad = true, hess = true, cons_j = true, cons_h = true)
u_opt = solve(prob, Optim.IPNewton())

# %% 5
using Plots
x_plot = -2:0.01:2
y_plot = -1:0.01:3
contour(
    x_plot, y_plot, (x, y) -> (1 - x)^2 + 100 * (y - x^2)^2, fill = true, color = :viridis,
    ratio = :equal, xlims = (-2, 2))
contour!(x_plot, y_plot, (x, y) -> x^2 + y^2, levels = [1], color = :lightblue, line = 4)
scatter!([u_opt[1]], [u_opt[2]], ms = 10, label = "minimum")
