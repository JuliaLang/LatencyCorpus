# env: sciml
# kind: overcompile
# source: examples/perturbation.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
@variables ϵ x(t)
eq = D(D(x)) ~ -(1 + ϵ * x)^(-2)

# %% 2
using Symbolics
x_coeffs = @variables x₀(t) x₁(t) x₂(t) # 0th, 1st and 2nd order coefficients
x_series = series(x_coeffs, ϵ)

# %% 3
eq_pert = substitute_in_deriv(eq, x => x_series) # also substitute inside D(D(x))
eqs_pert = taylor_coeff(eq_pert, ϵ, 0:2)

# %% 4
@mtkcompile sys = System(eqs_pert, t)

# %% 5
using OrdinaryDiffEq
u0 = [x₀ => 0.0, x₁ => 0.0, x₂ => 0.0, D(x₀) => 1.0, D(x₁) => 0.0, D(x₂) => 0.0]
prob = ODEProblem(sys, u0, (0.0, 3.0))
sol = solve(prob)

# %% 6
using Plots
ϵs = 0.0:0.1:1.0
plot(sol; idxs = [substitute(x_series, ϵ => ϵᵢ) for ϵᵢ in ϵs], label = permutedims(["ϵ = $ϵᵢ" for ϵᵢ in ϵs]))

# %% 7
eq = D(D(x)) + 2 * ϵ * D(x) + x ~ 0

# %% 8
eq_pert = substitute_in_deriv(eq, x => x_series)
eqs_pert = taylor_coeff(eq_pert, ϵ, 0:2)
@mtkcompile sys = System(eqs_pert, t)

# %% 9
u0 = [x₀ => 0.0, x₁ => 0.0, x₂ => 0.0, D(x₀) => 1.0, D(x₁) => 0.0, D(x₂) => 0.0]
prob = ODEProblem(sys, u0, (0.0, 50.0))
sol = solve(prob)
plot(sol, idxs = substitute(x_series, ϵ => 0.1); label = "Perturbative (ϵ=0.1)")

x_exact(t, ϵ) = exp(-ϵ * t) * sin(√(1 - ϵ^2) * t) / √(1 - ϵ^2)
@assert isapprox(
    sol(π/2; idxs = substitute(x_series, ϵ => 0.1)), x_exact(π/2, 0.1); atol = 1e-2) # compare around 1st peak # hide
plot!(sol.t, x_exact.(sol.t, 0.1); label = "Exact (ϵ=0.1)")
