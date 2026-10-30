# env: sciml
# kind: unknown
# source: examples/kepler_problem.md

# %% 1
import OrdinaryDiffEq as ODE
import OrdinaryDiffEqSymplecticRK: KahanLi6
import OrdinaryDiffEqRKN: DPRKN6, ERKN4
import OrdinaryDiffEqLowOrderRK: RK4
import Plots: plot, plot!
import LinearAlgebra: norm
H(q, p) = norm(p)^2 / 2 - inv(norm(q))
L(q, p) = q[1] * p[2] - p[1] * q[2]

pdot!(dp, p, q, params, t) = (dp .= - q / norm(q)^3)
qdot!(dq, p, q, params, t) = (dq .= p)

initial_position = [0.4, 0]
initial_momentum = [0.0, 2.0]
initial_cond = (initial_position, initial_momentum)
initial_first_integrals = (H(initial_cond...), L(initial_cond...))
tspan = (0, 20.0)
prob = ODE.DynamicalODEProblem(pdot!, qdot!, initial_momentum, initial_position, tspan)
sol = ODE.solve(prob, KahanLi6(), dt = 1 // 10)

# %% 2
plot_orbit(sol) = plot(sol, idxs = (3, 4), lab = "Orbit", title = "Kepler Problem Solution")

function plot_first_integrals(sol, H, L)
    plot(
        initial_first_integrals[1] .- map(u -> H(u.x[2], u.x[1]), sol.u),
        lab = "Energy variation", title = "First Integrals"
    )
    return plot!(
        initial_first_integrals[2] .- map(u -> L(u.x[2], u.x[1]), sol.u),
        lab = "Angular momentum variation"
    )
end
analysis_plot(sol, H, L) = plot(plot_orbit(sol), plot_first_integrals(sol, H, L))

# %% 3
analysis_plot(sol, H, L)

# %% 4
# dt is not necessary, because unlike symplectic integrators DPRKN6 is adaptive
sol2 = ODE.solve(prob, DPRKN6())
@show sol2.u |> length
analysis_plot(sol2, H, L)

# %% 5
# dt is not necessary, because unlike symplectic integrators ERKN4 is adaptive
sol3 = ODE.solve(prob, ERKN4())
@show sol3.u |> length
analysis_plot(sol3, H, L)

# %% 6
sol4 = ODE.solve(prob, ODE.Tsit5())
@show sol4.u |> length
analysis_plot(sol4, H, L)

# %% 7
import NonlinearSolve as NLS
import DiffEqCallbacks: ManifoldProjection

function plot_orbit2(sol)
    return plot(sol, vars = (1, 2), lab = "Orbit", title = "Kepler Problem Solution")
end

function plot_first_integrals2(sol, H, L)
    plot(
        initial_first_integrals[1] .- map(u -> H(u[1:2], u[3:4]), sol.u),
        lab = "Energy variation", title = "First Integrals"
    )
    return plot!(
        initial_first_integrals[2] .- map(u -> L(u[1:2], u[3:4]), sol.u),
        lab = "Angular momentum variation"
    )
end

analysis_plot2(sol, H, L) = plot(plot_orbit2(sol), plot_first_integrals2(sol, H, L))

function hamiltonian(du, u, params, t)
    q, p = u[1:2], u[3:4]
    qdot!(@view(du[1:2]), p, q, params, t)
    pdot!(@view(du[3:4]), p, q, params, t)
    return
end

prob2 = ODE.ODEProblem(hamiltonian, [initial_position; initial_momentum], tspan)
sol_ = ODE.solve(prob2, RK4(), dt = 1 // 5, adaptive = false)
analysis_plot2(sol_, H, L)

# %% 8
function first_integrals_manifold(residual, u, p, t)
    residual[1:2] .= initial_first_integrals[1] - H(u[1:2], u[3:4])
    residual[3:4] .= initial_first_integrals[2] - L(u[1:2], u[3:4])
    return
end

cb = ManifoldProjection(first_integrals_manifold, autodiff = NLS.AutoForwardDiff())
sol5 = ODE.solve(prob2, RK4(), dt = 1 // 5, adaptive = false, callback = cb)
analysis_plot2(sol5, H, L)

# %% 9
function energy_manifold(residual, u, p, t)
    residual[1:2] .= initial_first_integrals[1] - H(u[1:2], u[3:4])
    residual[3:4] .= 0
    return
end
energy_cb = ManifoldProjection(energy_manifold, autodiff = NLS.AutoForwardDiff())
sol6 = ODE.solve(prob2, RK4(), dt = 1 // 5, adaptive = false, callback = energy_cb)
analysis_plot2(sol6, H, L)

# %% 10
function angular_manifold(residual, u, p, t)
    residual[1:2] .= initial_first_integrals[2] - L(u[1:2], u[3:4])
    residual[3:4] .= 0
    return
end
angular_cb = ManifoldProjection(angular_manifold, autodiff = NLS.AutoForwardDiff())
sol7 = ODE.solve(prob2, RK4(), dt = 1 // 5, adaptive = false, callback = angular_cb)
analysis_plot2(sol7, H, L)
