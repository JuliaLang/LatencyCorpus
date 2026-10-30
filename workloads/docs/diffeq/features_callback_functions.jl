# env: sciml
# kind: unknown
# source: features/callback_functions.md

# %% 1
import DifferentialEquations as DE
import SciMLBase
import DiffEqCallbacks: PresetTimeCallback # no longer reexported by DifferentialEquations v8
function f(du, u, p, t)
    du[1] = -u[1]
    return
end
u0 = [10.0]
const V = 1
prob = DE.ODEProblem(f, u0, (0.0, 10.0))
sol = DE.solve(prob, DE.Tsit5())
import Plots: plot
plot(sol)

# %% 2
condition(u, t, integrator) = t == 4
affect!(integrator) = integrator.u[1] += 10
cb = DE.DiscreteCallback(condition, affect!)

# %% 3
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
plot(sol)

# %% 4
sol = DE.solve(prob, DE.Tsit5(), callback = cb, tstops = [4.0])
plot(sol)

# %% 5
dosetimes = [4.0, 8.0]
condition(u, t, integrator) = t ∈ dosetimes
affect!(integrator) = integrator.u[1] += 10
cb = DE.DiscreteCallback(condition, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb, tstops = dosetimes)
plot(sol)

# %% 6
dosetimes = [4.0, 6.0, 8.0]
condition(u, t, integrator) = t ∈ dosetimes && (u[1] < 1.0)
affect!(integrator) = integrator.u[1] += 10 * integrator.t
cb = DE.DiscreteCallback(condition, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb, tstops = dosetimes)
plot(sol)

# %% 7
dosetimes = [4.0, 8.0]
affect!(integrator) = integrator.u[1] += 10
cb = PresetTimeCallback(dosetimes, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
plot(sol)

# %% 8
function f(du, u, p, t)
    du[1] = -0.5 * u[1] + p
    du[2] = -0.5 * u[2]
    return
end

# %% 9
const tstop1 = [5.0]
const tstop2 = [8.0]

condition(u, t, integrator) = t in tstop1
condition2(u, t, integrator) = t in tstop2

# %% 10
function affect!(integrator)
    integrator.p = 1.5
    return
end

function affect2!(integrator)
    integrator.p = -1.5
    return
end

# %% 11
import DifferentialEquations as DE
save_positions = (true, true)

cb = DE.DiscreteCallback(condition, affect!; save_positions)

save_positions = (false, true)

cb2 = DE.DiscreteCallback(condition2, affect2!; save_positions)

cbs = DE.CallbackSet(cb, cb2)

# %% 12
u0 = [10.0; 10.0]
p = 0.0
prob = DE.ODEProblem(f, u0, (0.0, 10.0), p)

# %% 13
const tstop = [5.0; 8.0]
sol = DE.solve(prob, DE.Tsit5(), callback = cbs, tstops = tstop)
import Plots: plot
plot(sol)

# %% 14
# pruned: failed without tiering
# %% 15
mutable struct AutoAbstolAffect{T}
    curmax::T
end
# Now make `affect!` for this:
function (p::AutoAbstolAffect)(integrator)
    p.curmax = max(p.curmax, integrator.u)
    integrator.opts.abstol = p.curmax * integrator.opts.reltol
    return DE.derivative_discontinuity!(integrator, false)
end

# %% 16
function AutoAbstol(save = true; init_curmax = 1.0e-6)
    affect! = AutoAbstolAffect(init_curmax)
    condition = (u, t, integrator) -> true
    save_positions = (save, false)
    return DE.DiscreteCallback(condition, affect!; save_positions)
end

# %% 17
import DifferentialEquations as DE
import OrdinaryDiffEqLowOrderRK: BS3
cb = AutoAbstol(true; init_curmax = 1.0e-6)

# %% 18
g(u, p, t) = -u[1]
u0 = 10.0
const V = 1
prob = DE.ODEProblem(g, u0, (0.0, 10.0))
integrator = DE.init(prob, BS3(), callback = cb)
at1 = integrator.opts.abstol
DE.step!(integrator)
at2 = integrator.opts.abstol
at1 <= at2

# %% 19
DE.step!(integrator)
at3 = integrator.opts.abstol
at2 <= at3

# %% 20
function f(du, u, p, t)
    du[1] = u[2]
    du[2] = -p
    return
end

# %% 21
# Event when condition(u,t,integrator) == 0
condition(u, t, integrator) = u[1]

# %% 22
function affect!(integrator)
    integrator.u[2] = -integrator.u[2]
    return
end

# %% 23
import DifferentialEquations as DE
cb = DE.ContinuousCallback(condition, affect!)

# %% 24
u0 = [50.0, 0.0]
tspan = (0.0, 15.0)
p = 9.8
prob = DE.ODEProblem(f, u0, tspan, p)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
import Plots: plot
plot(sol)

# %% 25
u0 = [50.0, 0.0]
tspan = (0.0, 100.0)
prob = DE.ODEProblem(f, u0, tspan, p)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
plot(sol)

# %% 26
function dynamics!(du, u, p, t)
    du[1] = u[2]
    du[2] = p[1] * -9.8
    return
end
function floor_aff!(int)
    int.p[1] = 0
    int.u[2] = 0
    return @show int.u[1], int.t
end
floor_event = DE.ContinuousCallback(condition, floor_aff!)
u0 = [1.0, 0.0]
p = [1.0]
prob = DE.ODEProblem{true}(dynamics!, u0, (0.0, 1.75), p)
sol = DE.solve(prob, DE.Tsit5(), callback = floor_event)
plot(sol)

# %% 27
import SciMLBase
floor_event = DE.ContinuousCallback(condition, floor_aff!, rootfind = SciMLBase.RightRootFind)
u0 = [1.0, 0.0]
p = [1.0]
prob = DE.ODEProblem{true}(dynamics!, u0, (0.0, 1.75), p)
sol = DE.solve(prob, DE.Tsit5(), callback = floor_event)
sol.u[end] # [-1.2647055847076505e-15, 0.0]

# %% 28
function floor_aff!(int)
    int.p[1] = 0
    int.u[1] = 0
    int.u[2] = 0
    @show int.u[1], int.t
    return
end
floor_event = DE.ContinuousCallback(condition, floor_aff!)
u0 = [1.0, 0.0]
p = [1.0]
prob = DE.ODEProblem{true}(dynamics!, u0, (0.0, 1.75), p)
sol = DE.solve(prob, DE.Tsit5(), callback = floor_event)
sol.u[end] # [0.0,0.0]

# %% 29
function dynamics!(du, u, p, t)
    du[1] = u[2]
    du[2] = -9.8
    return
end
function floor_aff!(int)
    int.u[2] *= -0.5
    int.p[1] += 1
    int.p[2] = int.t
    return
end
floor_event = DE.ContinuousCallback(condition, floor_aff!)
u0 = [1.0, 0.0]
p = [0.0, 0.0]
prob = DE.ODEProblem{true}(dynamics!, u0, (0.0, 2.0), p)
sol = DE.solve(prob, DE.Tsit5(), callback = floor_event)
plot(sol)

# %% 30
function dynamics!(du, u, p, t)
    du[1] = u[2]
    du[2] = p[1] * -9.8
    return
end
function floor_aff!(int)
    int.u[2] *= -0.5
    if int.dt > 1.0e-12
        DE.set_proposed_dt!(int, (int.t - int.tprev) / 100)
    else
        int.u[1] = 0
        int.u[2] = 0
        int.p[1] = 0
    end
    int.p[2] += 1
    int.p[3] = int.t
    return
end
floor_event = DE.ContinuousCallback(condition, floor_aff!)
u0 = [1.0, 0.0]
p = [1.0, 0.0, 0.0]
prob = DE.ODEProblem{true}(dynamics!, u0, (0.0, 2.0), p)
sol = DE.solve(prob, DE.Tsit5(), callback = floor_event)
plot(sol)

# %% 31
p1 = plot(sol, idxs = 1, tspan = (1.25, 1.4))
p2 = plot(sol, idxs = 1, tspan = (1.35, 1.36))
p3 = plot(sol, idxs = 1, tspan = (1.354, 1.35526))
p4 = plot(sol, idxs = 1, tspan = (1.35526, 1.35526185))
plot(p1, p2, p3, p4)

# %% 32
import DifferentialEquations as DE
u0 = [1.0, 0.0]
function fun2(du, u, p, t)
    du[2] = -u[1]
    du[1] = u[2]
    return
end
tspan = (0.0, 10.0)
prob = DE.ODEProblem(fun2, u0, tspan)

# %% 33
condition(u, t, integrator) = u[2] > 0
affect!(integrator) = DE.terminate!(integrator)
cb = DE.DiscreteCallback(condition, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)

# %% 34
condition(u, t, integrator) = u[2]
affect!(integrator) = DE.terminate!(integrator)
cb = DE.ContinuousCallback(condition, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
import Plots: plot
plot(sol);

# %% 35
sol.t[end] # 3.1415902502224307

# %% 36
sol = DE.solve(prob, DE.Vern8(), callback = cb, reltol = 1.0e-12, abstol = 1.0e-12)
#π = 3.141592653589703...
sol.t[end] # 3.1415926535896035

# %% 37
condition(u, t, integrator) = u[2]
affect!(integrator) = DE.terminate!(integrator)
cb = DE.ContinuousCallback(condition, nothing, affect!)
sol = DE.solve(prob, DE.Tsit5(), callback = cb)
plot(sol)

# %% 38
const α = 0.3
function f(du, u, p, t)
    for i in 1:length(u)
        du[i] = α * u[i]
    end
    return
end

# %% 39
# Event when condition(u,t,integrator) == 0
condition(u, t, integrator) = 1 - maximum(u)

# %% 40
function affect!(integrator)
    u = integrator.u
    maxidx = findmax(u)[2]
    resize!(integrator, length(u) + 1)
    Θ = rand()
    u[maxidx] = Θ
    u[end] = 1 - Θ
    return
end

# %% 41
import DifferentialEquations as DE
callback = DE.ContinuousCallback(condition, affect!)
u0 = [0.2]
tspan = (0.0, 10.0)
prob = DE.ODEProblem(f, u0, tspan)
sol = DE.solve(prob; callback)

# %% 42
import Plots: plot
plot(
    sol.t, map(length, sol[:]), lw = 3,
    ylabel = "Number of Cells", xlabel = "Time"
)

# %% 43
ts = range(0, stop = 10, length = 100)
plot(
    ts, map(first, sol.(ts)), lw = 3,
    ylabel = "Amount of X in Cell 1", xlabel = "Time"
)

# %% 44
function f(du, u, p, t)
    du[1] = u[2]
    du[2] = -p
    du[3] = u[4]
    du[4] = 0.0
    return
end

# %% 45
function condition(out, u, t, integrator) # Event when condition(out,u,t,integrator) == 0
    out[1] = u[1]
    out[2] = (u[3] - 10.0)u[3]
    return
end

function affect!(integrator, idx)
    if idx == 1
        integrator.u[2] = -0.9integrator.u[2]
    elseif idx == 2
        integrator.u[4] = -0.9integrator.u[4]
    end
    return
end
import DifferentialEquations as DE
cb = DE.VectorContinuousCallback(condition, affect!, 2)

# %% 46
u0 = [50.0, 0.0, 0.0, 2.0]
tspan = (0.0, 15.0)
p = 9.8
prob = DE.ODEProblem(f, u0, tspan, p)
sol = DE.solve(prob, DE.Tsit5(), callback = cb, dt = 1.0e-3, adaptive = false)
import Plots: plot
plot(sol, idxs = (1, 3));
