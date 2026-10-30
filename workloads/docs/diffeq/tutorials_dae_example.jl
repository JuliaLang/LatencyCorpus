# env: sciml
# kind: unknown
# source: tutorials/dae_example.md

# %% 1
import DifferentialEquations as DE
import OrdinaryDiffEqRosenbrock: Rodas5
import Plots: plot
function rober(du, u, p, t)
    y₁, y₂, y₃ = u
    k₁, k₂, k₃ = p
    du[1] = -k₁ * y₁ + k₃ * y₂ * y₃
    du[2] = k₁ * y₁ - k₃ * y₂ * y₃ - k₂ * y₂^2
    du[3] = y₁ + y₂ + y₃ - 1
    return
end
M = Float64[
    1 0 0
    0 1 0
    0 0 0
]
f = DE.ODEFunction(rober, mass_matrix = M)
prob_mm = DE.ODEProblem(f, [1.0, 0.0, 0.0], (0.0, 1.0e5), (0.04, 3.0e7, 1.0e4))
sol = DE.solve(prob_mm, Rodas5(), reltol = 1.0e-8, abstol = 1.0e-8)

plot(sol, xscale = :log10, tspan = (1.0e-6, 1.0e5), layout = (3, 1))

# %% 2
function f2(out, du, u, p, t)
    out[1] = -0.04u[1] + 1.0e4 * u[2] * u[3] - du[1]
    out[2] = +0.04u[1] - 3.0e7 * u[2]^2 - 1.0e4 * u[2] * u[3] - du[2]
    out[3] = u[1] + u[2] + u[3] - 1.0
    return
end

# %% 3
u₀ = [1.0, 0, 0]
du₀ = [-0.04, 0.04, 0.0]
tspan = (0.0, 100000.0)

# %% 4
differential_vars = [true, true, false]
prob = DE.DAEProblem(f2, du₀, u₀, tspan; differential_vars)

# %% 5
import Sundials: IDA
import DiffEqBase
# Explicitly use Brown's initialization algorithm
sol = DE.solve(prob, IDA(), initializealg = DiffEqBase.BrownFullBasicInit())

# %% 6
# This will verify initial conditions and error if they're inconsistent
sol_check = DE.solve(prob, IDA(), initializealg = DiffEqBase.CheckInit())

# %% 7
plot(sol, xscale = :log10, tspan = (1.0e-6, 1.0e5), layout = (3, 1))

# %% 8
# Inconsistent initial conditions - y₃ should be 0 to satisfy y₁ + y₂ + y₃ = 1
u₀_inconsistent = [1.0, 0.0, 0.5]  # Sum is 1.5, not 1!
du₀_inconsistent = [-0.04, 0.04, 0.0]

prob_inconsistent = DE.DAEProblem(
    f2, du₀_inconsistent, u₀_inconsistent, tspan; differential_vars
)

# This would error with CheckInit() because conditions are inconsistent:
# sol_error = DE.solve(prob_inconsistent, IDA(),
#                      initializealg = DiffEqBase.CheckInit())

# But BrownFullBasicInit() will fix the inconsistency automatically:
sol_fixed = DE.solve(
    prob_inconsistent, IDA(),
    initializealg = DiffEqBase.BrownFullBasicInit()
)

println("Original (inconsistent) y₃ = ", u₀_inconsistent[3])
println("Corrected y₃ after initialization = ", sol_fixed.u[1][3])
println("Sum after correction = ", sum(sol_fixed.u[1]))
