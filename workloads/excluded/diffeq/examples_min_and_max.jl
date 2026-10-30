# env: sciml
# kind: unknown
# source: examples/min_and_max.md

# %% 1
#Constants and setup
import OrdinaryDiffEq as ODE
initial = [0.01, 0.01, 0.01, 0.01]
tspan = (0.0, 100.0)

#Define the problem
function double_pendulum_hamiltonian(udot, u, p, t)
    α, lα, β, lβ = u
    return udot .= [
        2(lα - (1 + cos(β))lβ) / (3 - cos(2β)),
        -2sin(α) - sin(α + β),
        2(-(1 + cos(β))lα + (3 + 2cos(β))lβ) / (3 - cos(2β)),
        -sin(α + β) - 2sin(β) * (((lα - lβ)lβ) / (3 - cos(2β))) +
            2sin(2β) * ((lα^2 - 2(1 + cos(β))lα * lβ + (3 + 2cos(β))lβ^2) / (3 - cos(2β))^2),
    ]
end

#Pass to solvers
poincare = ODE.ODEProblem(double_pendulum_hamiltonian, initial, tspan)

# %% 2
sol = ODE.solve(poincare, ODE.Tsit5())

# %% 3
import Plots: gr, plot, scatter!
gr()
plot(sol, vars = [(0, 3), (0, 4)], leg = false, plotdensity = 10000)

# %% 4
plot(sol, vars = (3, 4), leg = false)

# %% 5
f(t, _) = sol(first(t), idxs = 4)

# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
# %% 8
# pruned: failed without tiering
# %% 9
# pruned: failed without tiering
# %% 10
# pruned: failed without tiering
# %% 11
# pruned: failed without tiering
