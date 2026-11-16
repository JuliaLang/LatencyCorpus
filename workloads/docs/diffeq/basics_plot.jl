# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/basics/plot.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
import Plots: plot
function lorenz(du, u, p, t)
    du[1] = p[1] * (u[2] - u[1])
    du[2] = u[1] * (p[2] - u[3]) - u[2]
    du[3] = u[1] * u[2] - p[3] * u[3]
    return
end

u0 = [1.0, 5.0, 10.0]
tspan = (0.0, 100.0)
p = (10.0, 28.0, 8 / 3)
prob = DE.ODEProblem(lorenz, u0, tspan, p)
sol = DE.solve(prob)
xyzt = plot(sol, plotdensity = 10000, lw = 1.5)
xy = plot(sol, plotdensity = 10000, idxs = (1, 2))
xz = plot(sol, plotdensity = 10000, idxs = (1, 3))
yz = plot(sol, plotdensity = 10000, idxs = (2, 3))
xyz = plot(sol, plotdensity = 10000, idxs = (1, 2, 3))
plot(
    plot(xyzt, xyz),
    plot(xy, xz, yz, layout = (1, 3), w = 1),
    layout = (2, 1)
)

# %% 2
f(x, y, z) = (sqrt(x^2 + y^2 + z^2), x)
plot(sol, idxs = (f, 1, 2, 3))

# %% 3
f(t, x, y, z) = (t, sqrt(x^2 + y^2 + z^2))
plot(sol, idxs = (f, 0, 1, 2, 3))
