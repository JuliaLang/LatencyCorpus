# env: sciml
# kind: interactive
# source: examples/classical_physics.md

# %% 1
import OrdinaryDiffEq as ODE
import Plots: plot, plot!

#Half-life of Carbon-14 is 5,730 years.
t½ = 5.73

#Setup
u₀ = 1.0
tspan = (0.0, 30.0)

#Define the problem
radioactivedecay(u, p, t) = -log(2) / t½ * u

#Pass to solver
prob = ODE.ODEProblem(radioactivedecay, u₀, tspan)
sol = ODE.solve(prob, ODE.Tsit5())

#Plot
plot(
    sol, linewidth = 2, title = "Carbon-14 half-life",
    xaxis = "Time in thousands of years", yaxis = "Ratio left",
    label = "Numerical Solution"
)
plot!(sol.t, t -> 2^(-t / t½), lw = 3, ls = :dash, label = "Analytical Solution")

# %% 2
# Simple Harmonic Oscillator Problem
import OrdinaryDiffEq as ODE
import OrdinaryDiffEqRKN: DPRKN6
import Plots: plot, plot!

#Parameters
ω = 1

#Initial Conditions
x₀ = [0.0]
dx₀ = [π / 2]
tspan = (0.0, 2π)

ϕ = atan((dx₀[1] / ω) / x₀[1])
A = √(x₀[1]^2 + dx₀[1]^2)

#Define the problem
function harmonicoscillator(ddu, du, u, ω, t)
    return ddu .= -ω^2 * u
end

#Pass to solvers
prob = ODE.SecondOrderODEProblem(harmonicoscillator, dx₀, x₀, tspan, ω)
sol = ODE.solve(prob, DPRKN6())

#Plot
plot(
    sol, idxs = [2, 1], linewidth = 2, title = "Simple Harmonic Oscillator",
    xaxis = "Time", yaxis = "Elongation", label = ["x" "dx"]
)
plot!(t -> A * cos(ω * t - ϕ), lw = 3, ls = :dash, label = "Analytical Solution x")
plot!(t -> -A * ω * sin(ω * t - ϕ), lw = 3, ls = :dash, label = "Analytical Solution dx")

# %% 3
# Simple Pendulum Problem
import OrdinaryDiffEq as ODE
import Plots: plot, plot!

#Constants
const g = 9.81
L = 1.0

#Initial Conditions
u₀ = [0, π / 2]
tspan = (0.0, 6.3)

#Define the problem
function simplependulum(du, u, p, t)
    θ, ω = u
    du[1] = ω
    du[2] = -(g / L) * sin(θ)
    return
end

#Pass to solvers
prob = ODE.ODEProblem(simplependulum, u₀, tspan)
sol = ODE.solve(prob, ODE.Tsit5())

#Plot
plot(
    sol, linewidth = 2, title = "Simple Pendulum Problem", xaxis = "Time",
    yaxis = "Height", label = ["θ" "ω"]
)

# %% 4
p = plot(
    sol, vars = (1, 2), xlims = (-9, 9), title = "Phase Space Plot",
    xaxis = "Angular position", yaxis = "Angular velocity", leg = false
)
function phase_plot(prob, u0, p, tspan = 2pi)
    _prob = ODE.ODEProblem(prob.f, u0, (0.0, tspan))
    sol = ODE.solve(_prob, ODE.Vern9()) # Use Vern9 solver for higher accuracy
    return plot!(p, sol, idxs = (1, 2))
end
for i in (-4pi):(pi / 2):(4π)
    for j in (-4pi):(pi / 2):(4π)
        phase_plot(prob, [j, i], p)
    end
end
plot(p, xlims = (-9, 9))

# %% 5
#Double Pendulum Problem
import OrdinaryDiffEq as ODE
import Plots: plot, plot!, scatter, scatter!

#Constants and setup
const m₁, m₂, L₁, L₂ = 1, 2, 1, 2
initial = [0, π / 3, 0, 3pi / 5]
tspan = (0.0, 50.0)

#Convenience function for transforming from polar to Cartesian coordinates
function polar2cart(sol; dt = 0.02, l1 = L₁, l2 = L₂, vars = (2, 4))
    u = sol.t[1]:dt:sol.t[end]

    p1 = l1 * map(x -> x[vars[1]], sol.(u))
    p2 = l2 * map(y -> y[vars[2]], sol.(u))

    x1 = l1 * sin.(p1)
    y1 = l1 * -cos.(p1)
    r = (
        x1 + l2 * sin.(p2),
        y1 - l2 * cos.(p2),
    )
    return (u, r)
end

#Define the Problem
function double_pendulum(xdot, x, p, t)
    θ₁, ω₁, θ₂, ω₂ = x
    Δθ = θ₁ - θ₂
    sΔ, cΔ = sincos(Δθ)
    xdot[1] = ω₁
    xdot[2] = -(
        (
            g * (2m₁ + m₂) * sin(θ₁) +
                m₂ * g * sin(θ₁ - 2θ₂) +
                2m₂ * (L₂ * ω₂^2 + L₁ * ω₁^2 * cΔ) * sΔ
        ) /
            (2L₁ * (m₁ + m₂ * sΔ^2))
    )
    xdot[3] = ω₂
    return xdot[4] = ((m₁ + m₂) * (L₁ * ω₁^2 + g * cos(θ₁)) + L₂ * m₂ * ω₂^2 * cΔ) * sΔ /
        (L₂ * (m₁ + m₂ * sΔ^2))
end

#Pass to Solvers
double_pendulum_problem = ODE.ODEProblem(double_pendulum, initial, tspan)
sol = ODE.solve(double_pendulum_problem, ODE.Vern7(), abstol = 1.0e-10, dt = 0.05);

# %% 6
#Obtain coordinates in Cartesian Geometry
ts, ps = polar2cart(sol, l1 = L₁, l2 = L₂, dt = 0.01)
plot(ps...)

# %% 7
#Constants and setup
initial2 = [0.01, 0.005, 0.01, 0.01]
tspan2 = (0.0, 500.0)

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

# Construct a ContinuousCallback
condition(u, t, integrator) = u[1]
affect!(integrator) = nothing
cb = ODE.ContinuousCallback(
    condition, affect!, nothing,
    save_positions = (true, false)
)

# Construct Problem
poincare = ODE.ODEProblem(double_pendulum_hamiltonian, initial2, tspan2)
sol2 = ODE.solve(
    poincare, ODE.Vern9(), save_everystep = false, save_start = false,
    save_end = false, callback = cb, abstol = 1.0e-16, reltol = 1.0e-16
)

function poincare_map(prob, u₀, p; callback = cb)
    _prob = ODE.ODEProblem(prob.f, u₀, prob.tspan)
    sol = ODE.solve(
        _prob, ODE.Vern9(), save_everystep = false, save_start = false,
        save_end = false, callback = cb, abstol = 1.0e-16, reltol = 1.0e-16
    )
    return scatter!(p, sol, idxs = (3, 4), markersize = 3, msw = 0)
end

# %% 8
lβrange = -0.02:0.0025:0.02
p = scatter(sol2, idxs = (3, 4), leg = false, markersize = 3, msw = 0)
for lβ in lβrange
    poincare_map(poincare, [0.01, 0.01, 0.01, lβ], p)
end
plot(p, xlabel = "β", ylabel = "l_β", ylims = (0, 0.03))

# %% 9
import OrdinaryDiffEq as ODE
import Plots: plot, plot!

#Setup
initial = [0.0, 0.1, 0.5, 0]
tspan = (0, 100.0)

#Remember, V is the potential of the system and T is the Total Kinetic Energy, thus E will
#the total energy of the system.
V(x, y) = 1 // 2 * (x^2 + y^2 + 2x^2 * y - 2 // 3 * y^3)
E(x, y, dx, dy) = V(x, y) + 1 // 2 * (dx^2 + dy^2);

#Define the function
function Hénon_Heiles(du, u, p, t)
    x, y, dx, dy = u
    du[1] = dx
    du[2] = dy
    du[3] = -x - 2x * y
    du[4] = y^2 - y - x^2
    return
end

#Pass to solvers
prob = ODE.ODEProblem(Hénon_Heiles, initial, tspan)
sol = ODE.solve(prob, ODE.Vern9(), abstol = 1.0e-16, reltol = 1.0e-16);

# %% 10
# Plot the orbit
plot(
    sol, idxs = (1, 2), title = "The orbit of the Hénon-Heiles system",
    xaxis = "x", yaxis = "y", leg = false
)

# %% 11
#Optional Sanity check - what do you think this returns and why?
@show sol.retcode

#Plot -
plot(
    sol, idxs = (1, 3), title = "Phase space for the Hénon-Heiles system",
    xaxis = "Position", yaxis = "Velocity"
)
plot!(sol, idxs = (2, 4), leg = false)

# %% 12
#We map the Total energies during the time intervals of the solution (sol.u here) to a new vector
#pass it to the plotter a bit more conveniently
energy = map(x -> E(x...), sol.u)

#We use @show here to easily spot erratic behavior in our system by seeing if the loss in energy was too great.
@show ΔE = energy[1] - energy[end]

#Plot
plot(
    sol.t, energy .- energy[1], title = "Change in Energy over Time",
    xaxis = "Time in iterations", yaxis = "Change in Energy"
)

# %% 13
import OrdinaryDiffEqSymplecticRK as ODESymp # KahanLi8
function HH_acceleration!(dv, v, u, p, t)
    x, y = u
    dx, dy = dv
    dv[1] = -x - 2x * y
    dv[2] = y^2 - y - x^2
    return
end
initial_positions = [0.0, 0.1]
initial_velocities = [0.5, 0.0]
prob = ODE.SecondOrderODEProblem(HH_acceleration!, initial_velocities, initial_positions, tspan)
sol2 = ODE.solve(prob, ODESymp.KahanLi8(), dt = 1 / 10);

# %% 14
# Plot the orbit
plot(
    sol2, idxs = (3, 4), title = "The orbit of the Hénon-Heiles system",
    xaxis = "x", yaxis = "y", leg = false
)

# %% 15
plot(
    sol2, idxs = (3, 1), title = "Phase space for the Hénon-Heiles system",
    xaxis = "Position", yaxis = "Velocity"
)
plot!(sol2, idxs = (4, 2), leg = false)

# %% 16
energy = map(x -> E(x[3], x[4], x[1], x[2]), sol2.u)
#We use @show here to easily spot erratic behaviour in our system by seeing if the loss in energy was too great.
@show ΔE = energy[1] - energy[end]

#Plot
plot(
    sol2.t, energy .- energy[1], title = "Change in Energy over Time",
    xaxis = "Time in iterations", yaxis = "Change in Energy"
)

# %% 17
sol3 = ODE.solve(prob, DPRKN6());
energy = map(x -> E(x[3], x[4], x[1], x[2]), sol3.u)
@show ΔE = energy[1] - energy[end]
plot(
    sol3.t, energy .- energy[1], title = "Change in Energy over Time",
    xaxis = "Time in iterations", yaxis = "Change in Energy"
)
