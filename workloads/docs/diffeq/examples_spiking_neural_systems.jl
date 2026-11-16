# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/examples/spiking_neural_systems.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
import DiffEqCallbacks: PresetTimeCallback # no longer reexported by DifferentialEquations v8
import ComponentArrays: ComponentArray
import Plots: plot, plot!, gr
gr()

function lif(u, p, t)
    gL, EL, C, Vth, I = p
    return (-gL * (u - EL) + I) / C
end

# %% 2
thr(u, t, integrator) = u - integrator.p.Vth

function reset!(integrator)
    integrator.u = integrator.p.EL
    return
end

threshold = DE.ContinuousCallback(thr, reset!, nothing)
current_step = PresetTimeCallback([2, 15], integrator -> integrator.p.I += 150.0)
callback = DE.CallbackSet(current_step, threshold)

# %% 3
u0 = -75
tspan = (0.0, 40.0)
p = ComponentArray(gL = 5.0, EL = -75.0, C = 50.0, Vth = -55.0, I = 0)

prob = DE.ODEProblem(lif, u0, tspan, p; callback)

# %% 4
sol = DE.solve(prob)

# %% 5
plot(sol)

# %% 6
# Izhikevichch Model
import DifferentialEquations as DE
import DiffEqCallbacks: PresetTimeCallback

function izh!(du, u, p, t)
    a, b, c, d, I = p

    du[1] = 0.04 * u[1]^2 + 5 * u[1] + 140 - u[2] + I
    du[2] = a * (b * u[1] - u[2])
    return
end

# %% 7
thr(u, t, integrator) = integrator.u[1] >= 30

function reset!(integrator)
    integrator.u[1] = integrator.p[3]
    integrator.u[2] += integrator.p[4]
    return
end

threshold = DE.DiscreteCallback(thr, reset!)
current_step = PresetTimeCallback(50, integrator -> integrator.p[5] += 10)
callback = DE.CallbackSet(current_step, threshold)

# %% 8
p = [0.02, 0.2, -50, 2, 0]
u0 = [-65, p[2] * -65]
tspan = (0.0, 300)

prob = DE.ODEProblem(izh!, u0, tspan, p; callback)

# %% 9
sol = DE.solve(prob)
plot(sol, vars = 1)

# %% 10
plot(sol, vars = 2)

# %% 11
p = [0.02, 0.2, -65, 8, 0]
u0 = [-65, p[2] * -65]
tspan = (0.0, 300)

prob = DE.ODEProblem(izh!, u0, tspan, p; callback)
sol = DE.solve(prob)
plot(sol, vars = 1)

# %% 12
import DifferentialEquations as DE
import DiffEqCallbacks: PresetTimeCallback

# Potassium ion-channel rate functions
alpha_n(v) = (0.02 * (v - 25.0)) / (1.0 - exp(-(v - 25.0) / 9.0))
beta_n(v) = (-0.002 * (v - 25.0)) / (1.0 - exp((v - 25.0) / 9.0))

# Sodium ion-channel rate functions
alpha_m(v) = (0.182 * (v + 35.0)) / (1.0 - exp(-(v + 35.0) / 9.0))
beta_m(v) = (-0.124 * (v + 35.0)) / (1.0 - exp((v + 35.0) / 9.0))

alpha_h(v) = 0.25 * exp(-(v + 90.0) / 12.0)
beta_h(v) = (0.25 * exp((v + 62.0) / 6.0)) / exp((v + 90.0) / 12.0)

function HH!(du, u, p, t)
    gK, gNa, gL, EK, ENa, EL, C, I = p
    v, n, m, h = u

    du[1] = (
        -(gK * n^4 * (v - EK)) - (gNa * m^3 * h * (v - ENa)) -
            (gL * (v - EL)) + I
    ) / C
    du[2] = (alpha_n(v) * (1.0 - n)) - (beta_n(v) * n)
    du[3] = (alpha_m(v) * (1.0 - m)) - (beta_m(v) * m)
    du[4] = (alpha_h(v) * (1.0 - h)) - (beta_h(v) * h)
    return
end

# %% 13
current_step = PresetTimeCallback(100, integrator -> integrator.p[8] += 1)

# n, m & h steady-states
n_inf(v) = alpha_n(v) / (alpha_n(v) + beta_n(v))
m_inf(v) = alpha_m(v) / (alpha_m(v) + beta_m(v))
h_inf(v) = alpha_h(v) / (alpha_h(v) + beta_h(v))

p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0]
u0 = [-60, n_inf(-60), m_inf(-60), h_inf(-60)]
tspan = (0.0, 1000)

prob = DE.ODEProblem(HH!, u0, tspan, p, callback = current_step)

# %% 14
sol = DE.solve(prob);
plot(sol, vars = 1)

# %% 15
plot(sol, vars = [2, 3, 4], tspan = (105.0, 130.0))

# %% 16
function gSyn(max_gsyn, tau, tf, t)
    if t - tf >= 0
        return max_gsyn * exp(-(t - tf) / tau)
    else
        return 0.0
    end
end
function HH!(du, u, p, t)
    gK, gNa, gL, EK, ENa, EL, C, I, max_gSyn, ESyn, tau, tf = p
    v, n, m, h = u

    ISyn = gSyn(max_gSyn, tau, tf, t) * (v - ESyn)

    du[1] = (
        -(gK * n^4 * (v - EK)) - (gNa * m^3 * h * (v - ENa)) -
            (gL * (v - EL)) + I - ISyn
    ) / C
    du[2] = (alpha_n(v) * (1.0 - n)) - (beta_n(v) * n)
    du[3] = (alpha_m(v) * (1.0 - m)) - (beta_m(v) * m)
    du[4] = (alpha_h(v) * (1.0 - h)) - (beta_h(v) * h)
    return
end

# %% 17
p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0, 0.008, 0, 20, 100]
tspan = (0.0, 200)
prob = DE.ODEProblem(HH!, u0, tspan, p)
sol = DE.solve(prob);
plot(sol, vars = 1)

# %% 18
p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0, 0.01, 0, 20, 100]
tspan = (0.0, 200)
prob = DE.ODEProblem(HH!, u0, tspan, p)
sol = DE.solve(prob);
plot!(sol, vars = 1)

# %% 19
function HH!(du, u, p, t)
    gK, gNa, gL, EK, ENa, EL, C, I, tau, tau_u, tau_R, u0, gmax, Esyn = p
    v, n, m, h, u, R, gsyn = u

    du[1] = (
        (gK * n^4 * (EK - v)) + (gNa * m^3 * h * (ENa - v)) + (gL * (EL - v)) +
            I + gsyn * (Esyn - v)
    ) / C
    du[2] = (alpha_n(v) * (1.0 - n)) - (beta_n(v) * n)
    du[3] = (alpha_m(v) * (1.0 - m)) - (beta_m(v) * m)
    du[4] = (alpha_h(v) * (1.0 - h)) - (beta_h(v) * h)

    # Synaptic variables
    du[5] = -(u / tau_u)
    du[6] = (1 - R) / tau_R
    du[7] = -(gsyn / tau)
    return
end

function epsp!(integrator)
    integrator.u[5] += integrator.p[12] * (1 - integrator.u[5])
    integrator.u[7] += integrator.p[13] * integrator.u[5] * integrator.u[6]
    integrator.u[6] -= integrator.u[5] * integrator.u[6]
    return
end

epsp_ts = PresetTimeCallback(100:100:500, epsp!)

p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0, 30, 1000, 50, 0.5, 0.005, 0]
u0 = [-60, n_inf(-60), m_inf(-60), h_inf(-60), 0.0, 1.0, 0.0]
tspan = (0.0, 700)
prob = DE.ODEProblem(HH!, u0, tspan, p, callback = epsp_ts)
sol = DE.solve(prob);
plot(sol, vars = 1)

# %% 20
plot(sol, vars = 7)

# %% 21
plot(sol, vars = [5, 6])

# %% 22
epsp_ts = PresetTimeCallback(100:1000:5100, epsp!)

p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0, 30, 500, 50, 0.5, 0.005, 0]
u0 = [-60, n_inf(-60), m_inf(-60), h_inf(-60), 0.0, 1.0, 0.0]
tspan = (0.0, 5300)
prob = DE.ODEProblem(HH!, u0, tspan, p, callback = epsp_ts)
sol = DE.solve(prob);
plot(sol, vars = 7)

# %% 23
plot(sol, vars = [5, 6])

# %% 24
epsp_ts = PresetTimeCallback(100:100:500, epsp!)

p = [35.0, 40.0, 0.3, -77.0, 55.0, -65.0, 1, 0, 30, 100, 1000, 0.5, 0.005, 0]
u0 = [-60, n_inf(-60), m_inf(-60), h_inf(-60), 0.0, 1.0, 0.0]
tspan = (0.0, 700)
prob = DE.ODEProblem(HH!, u0, tspan, p, callback = epsp_ts)
sol = DE.solve(prob);
plot(sol, vars = 7)

# %% 25
plot(sol, vars = [5, 6])
