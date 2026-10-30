# env: sciml
# kind: unknown
# source: basics/Limiting.md

# %% 1
using ModelingToolkit, NonlinearSolve

function pnjlim(vnew, vold, vt, vcrit)
    if vnew > vcrit && abs(vnew - vold) > 2vt
        if vold > 0
            arg = 1 + (vnew - vold) / vt
            vnew = arg > 0 ? vold + vt * log(arg) : vcrit
        else
            vnew = vt * log(vnew / vt)
        end
    end
    return vnew
end
@register_symbolic pnjlim(vnew, vold, vt, vcrit)

function DCDiode(; name, Is = 1.0e-14, Vt = 0.025)
    @variables v i
    ps = @parameters begin
        (Is::Float64 = Is)
        (Vt::Float64 = Vt)
        (vcrit::Float64 = Vt * log(Vt / (sqrt(2) * Is)))
    end
    eqs = [i ~ Is * (exp(limited(v, pnjlim(limitnew, limitold, Vt, vcrit)) / Vt) - 1)]
    return System(eqs, [v, i], ps; name)
end

function DCResistor(; name, R = 1.0e3)
    @variables v i
    @parameters R = R
    return System([v ~ i * R], [v, i], [R]; name)
end

@named diode = DCDiode()
@named res = DCResistor()
@parameters Vs = 5.0
connections = [res.i ~ diode.i, Vs ~ res.v + diode.v]
@named circuit = System(connections, [], [Vs]; systems = [diode, res])
csys = mtkcompile(circuit)

prob = NonlinearProblem(csys, [diode.v => 0.0, res.i => 0.0])
sol = solve(prob, NewtonRaphson())
sol[diode.v], sol[diode.i], sol.stats.nsteps

# %% 2
using ModelingToolkit: t_nounits as t, D_nounits as D
using OrdinaryDiffEqSDIRK
import OrdinaryDiffEqNonlinearSolve

@variables v(t) = 0.0
@parameters Is = 1e-14 Vt = 0.025 C = 1e-6 R = 1e3 Vsrc = 5.0
vcrit = 0.71
rc = [D(v) ~ ((Vsrc - v) / R -
              Is * (exp(limited(v, pnjlim(limitnew, limitold, Vt, vcrit)) / Vt) - 1)) / C]
@mtkcompile rcsys = System(rc, t)

prob = ODEProblem(rcsys, [], (0.0, 1e-4); nlstep = true)
alg = ImplicitEuler(nlsolve = OrdinaryDiffEqNonlinearSolve.NonlinearSolveAlg())
sol = solve(prob, alg; dt = 1e-6, adaptive = false)
sol[v, end]

# %% 3
@variables c(t) = 0.5 [bounds = (0.0, 1.0)]
@parameters k = 1.0
@mtkcompile csys2 = System([D(c) ~ -k * c^2 * (1 - c)], t)

bprob = ODEProblem(csys2, [], (0.0, 1.0); nlstep = true)
bprob.f.nlstep_data.nlprob.lb, haskey(bprob.f.nlstep_data.nlprob.kwargs, :postcondition)
