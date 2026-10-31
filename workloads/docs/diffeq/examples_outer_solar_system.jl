# env: sciml
# kind: interactive
# source: examples/outer_solar_system.md

# %% 1
import OrdinaryDiffEq as ODE
using ModelingToolkit: System, t_nounits as t, D_nounits as D, @mtkbuild, @variables
using Symbolics: gradient
using Plots: plot, plot!

G = 2.95912208286e-4
M = [
    1.00000597682,
    9.54786104043e-4,
    2.85583733151e-4,
    4.37273164546e-5,
    5.17759138449e-5,
    1 / 1.3e8,
]
planets = ["Sun", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]

pos = [
    0.0 -3.5023653  9.0755314   8.310142   11.4707666 -15.5387357
    0.0 -3.8169847 -3.0458353 -16.2901086 -25.7294829 -25.2225594
    0.0 -1.5507963 -1.6483708  -7.2521278 -10.8169456  -3.1902382
]
vel = [
    0.0 0.00565429 0.00168318 0.00354178 0.0028893 0.00276725
    0.0 -0.0041249 0.00483525 0.00137102 0.00114527 -0.00170702
    0.0 -0.00190589 0.00192462 0.00055029 0.00039677 -0.00136504
]
tspan = (0.0, 200_000.0)

# %% 2
const ∑ = sum
const N = 6
@variables u(t)[1:3, 1:N]
u = collect(u)
potential = -G *
    ∑(
    i -> ∑(j -> (M[i] * M[j]) / √(∑(k -> (u[k, i] - u[k, j])^2, 1:3)), 1:(i - 1)),
    2:N
)

# %% 3
eqs = vec(@. D(D(u))) .~ .-gradient(potential, vec(u)) ./ repeat(M, inner = 3)
@mtkbuild sys = System(eqs, t)
prob = ODE.ODEProblem(sys, [vec(u .=> pos); vec(D.(u) .=> vel)], tspan)
sol = ODE.solve(prob, ODE.Tsit5());

# %% 4
plt = plot(xlab = "x", ylab = "y", zlab = "z", title = "Outer solar system")
for i in 1:N
    plot!(plt, sol, idxs = (u[:, i]...,), lab = planets[i])
end
plt
