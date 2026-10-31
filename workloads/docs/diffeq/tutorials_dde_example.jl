# env: sciml
# kind: interactive
# source: tutorials/dde_example.md

# %% 1
import DelayDiffEq as DDE
import DifferentialEquations: Tsit5
import OrdinaryDiffEqLowOrderRK: RK4
function bc_model(du, u, h, p, t)
    p0, q0, v0, d0, p1, q1, v1, d1, d2, beta0, beta1, tau = p
    hist3 = h(p, t - tau)[3]
    du[1] = (v0 / (1 + beta0 * hist3^2)) * (p0 - q0) * u[1] - d0 * u[1]
    du[2] = (v0 / (1 + beta0 * hist3^2)) * (1 - p0 + q0) * u[1] +
        (v1 / (1 + beta1 * hist3^2)) * (p1 - q1) * u[2] - d1 * u[2]
    du[3] = (v1 / (1 + beta1 * hist3^2)) * (1 - p1 + q1) * u[2] - d2 * u[3]
    return
end

# %% 2
h(p, t) = ones(3)

# %% 3
tau = 1
lags = [tau]

# %% 4
p0 = 0.2;
q0 = 0.3;
v0 = 1;
d0 = 5;
p1 = 0.2;
q1 = 0.3;
v1 = 1;
d1 = 1;
d2 = 1;
beta0 = 1;
beta1 = 1;
p = (p0, q0, v0, d0, p1, q1, v1, d1, d2, beta0, beta1, tau)
tspan = (0.0, 10.0)
u0 = [1.0, 1.0, 1.0]

prob = DDE.DDEProblem(bc_model, u0, h, tspan, p; constant_lags = lags)

# %% 5
alg = DDE.MethodOfSteps(Tsit5())

# %% 6
sol = DDE.solve(prob, alg);
@info "Solution computed with $(length(sol.t)) timesteps" # hide
nothing # hide

# %% 7
import Plots: plot
plot(sol)

# %% 8
h(out, p, t) = (out .= 1.0)

# %% 9
const out = zeros(3) # Define a cache variable
function bc_model(du, u, h, p, t)
    h(out, p, t - tau) # updates out to be the correct history function
    du[1] = (v0 / (1 + beta0 * out[3]^2)) * (p0 - q0) * u[1] - d0 * u[1]
    du[2] = (v0 / (1 + beta0 * out[3]^2)) * (1 - p0 + q0) * u[1] +
        (v1 / (1 + beta1 * out[3]^2)) * (p1 - q1) * u[2] - d1 * u[2]
    du[3] = (v1 / (1 + beta1 * out[3]^2)) * (1 - p1 + q1) * u[2] - d2 * u[3]
    return
end

# %% 10
function bc_model(du, u, h, p, t)
    u3_past_sq = h(p, t - tau; idxs = 3)^2
    du[1] = (v0 / (1 + beta0 * (u3_past_sq))) * (p0 - q0) * u[1] - d0 * u[1]
    du[2] = (v0 / (1 + beta0 * (u3_past_sq))) * (1 - p0 + q0) * u[1] +
        (v1 / (1 + beta1 * (u3_past_sq))) * (p1 - q1) * u[2] - d1 * u[2]
    du[3] = (v1 / (1 + beta1 * (u3_past_sq))) * (1 - p1 + q1) * u[2] - d2 * u[3]
    return
end

# %% 11
h(p, t; idxs = nothing) = typeof(idxs) <: Number ? 1.0 : ones(3)

# %% 12
h(p, t, ::Type{Val{1}}) = zeros(3)

# %% 13
prob = DDE.DDEProblem(bc_model, u0, h, tspan)
alg = DDE.MethodOfSteps(RK4())
sol = DDE.solve(prob, alg);
nothing # hide

# %% 14
prob = DDE.DDEProblem(bc_model, u0, h, tspan; dependent_lags = ((u, p, t) -> tau,))
alg = DDE.MethodOfSteps(Tsit5())
sol = DDE.solve(prob, alg);
nothing # hide
