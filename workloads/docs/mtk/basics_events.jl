# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/basics/Events.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkit: t_nounits as t, D_nounits as D

function UnitMassWithFriction(k; name)
    @variables x(t)=0 v(t)=0
    eqs = [D(x) ~ v
           D(v) ~ sin(t) - k * sign(v)]
    System(eqs, t; continuous_events = [v ~ 0], name) # when v = 0 there is a discontinuity
end
@mtkcompile m = UnitMassWithFriction(0.7)
prob = ODEProblem(m, Pair[], (0, 10pi))
sol = solve(prob, Tsit5())
plot(sol)

# %% 2
@variables x(t)=1 v(t)=0

root_eqs = [x ~ 0]  # the event happens at the ground x(t) = 0
affect = [v ~ -Pre(v)] # the effect is that the velocity changes sign

@mtkcompile ball = System(
    [D(x) ~ v
     D(v) ~ -9.8], t; continuous_events = root_eqs => affect) # equation => affect

tspan = (0.0, 5.0)
prob = ODEProblem(ball, Pair[], tspan)
sol = solve(prob, Tsit5())
@assert 0 <= minimum(sol[x]) <= 1e-10 # the ball never went through the floor but got very close
plot(sol)

# %% 3
@variables x(t)=1 y(t)=0 vx(t)=0 vy(t)=2

continuous_events = [[x ~ 0] => [vx ~ -Pre(vx)]
                     [y ~ -1.5, y ~ 1.5] => [vy ~ -Pre(vy)]]

@mtkcompile ball = System(
    [
        D(x) ~ vx,
        D(y) ~ vy,
        D(vx) ~ -9.8 - 0.1vx, # gravity + some small air resistance
        D(vy) ~ -0.1vy
    ], t; continuous_events)

tspan = (0.0, 10.0)
prob = ODEProblem(ball, Pair[], tspan)

sol = solve(prob, Tsit5())
@assert 0 <= minimum(sol[x]) <= 1e-10 # the ball never went through the floor but got very close
@assert minimum(sol[y]) >= -1.5 # check wall conditions
@assert maximum(sol[y]) <= 1.5  # check wall conditions

tv = sort([LinRange(0, 10, 200); sol.t])
plot(sol(tv)[y], sol(tv)[x], line_z = tv)
vline!([-1.5, 1.5], l = (:black, 5), primary = false)
hline!([0], l = (:black, 5), primary = false)

# %% 4
sts = @variables x(t), v(t)
par = @parameters g = 9.8
bb_eqs = [D(x) ~ v
          D(v) ~ -g]

function bb_affect!(mod, obs, integ, ctx)
    return (; v = -mod.v)
end

reflect = [x ~ 0] => (bb_affect!, (; v))

@mtkcompile bb_sys = System(bb_eqs, t, sts, par,
    continuous_events = reflect)

u0 = [v => 0.0, x => 1.0]

bb_prob = ODEProblem(bb_sys, u0, (0, 5.0))
bb_sol = solve(bb_prob, Tsit5())

plot(bb_sol)

# %% 5
@parameters M tinject
@discretes α(t)
@variables N(t)
Dₜ = Differential(t)
eqs = [Dₜ(N) ~ α - N]

# at time tinject we inject M cells
injection = (t == tinject) => [N ~ Pre(N) + M]

u0 = [N => 0.0]
tspan = (0.0, 20.0)
p = [α => 100.0, tinject => 10.0, M => 50]
@mtkcompile osys = System(eqs, t, [N], [α, M, tinject]; discrete_events = injection)
oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)
plot(sol)

# %% 6
injection = ((t == tinject) & (N < 50)) => [N ~ Pre(N) + M]

@mtkcompile osys = System(eqs, t, [N], [M, tinject, α]; discrete_events = injection)
oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)
plot(sol)

# %% 7
@parameters tkill

# we reset the first event to just occur at tinject
injection = (t == tinject) => [N ~ Pre(N) + M]

# at time tkill we turn off production of cells
killing = ModelingToolkit.SymbolicDiscreteCallback(
    (t == tkill) => [α ~ 0.0]; discrete_parameters = α, iv = t)

tspan = (0.0, 30.0)
p = [α => 100.0, tinject => 10.0, M => 50, tkill => 20.0]
@mtkcompile osys = System(eqs, t, [N], [α, M, tinject, tkill];
    discrete_events = [injection, killing])
oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = [10.0, 20.0])
plot(sol)

# %% 8
injection = [10.0] => [N ~ Pre(N) + M]
killing = ModelingToolkit.SymbolicDiscreteCallback(
    [20.0] => [α ~ 0.0], discrete_parameters = α, iv = t)

p = [α => 100.0, M => 50]
@mtkcompile osys = System(eqs, t, [N], [α, M];
    discrete_events = [injection, killing])
oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5())
plot(sol)

# %% 9
@variables x(t)
@discretes c(t)

ev = ModelingToolkit.SymbolicDiscreteCallback(
    1.0 => [c ~ Pre(c) + 1], discrete_parameters = c, iv = t)
@mtkcompile sys = System(
    D(x) ~ c * cos(x), t, [x], [c]; discrete_events = [ev])

prob = ODEProblem(sys, [x => 0.0, c => 1.0], (0.0, 2pi))
sol = solve(prob, Tsit5())
sol[c]

# %% 10
sol([1.0, 2.0], idxs = [c, c * cos(x)])

# %% 11
@variables temp(t)
@parameters furnace_on_threshold=0.5 furnace_off_threshold=0.7 furnace_power=1.0 leakage=0.1
@discretes furnace_on(t)::Bool = false
params = [furnace_on_threshold, furnace_off_threshold, furnace_power, leakage, furnace_on]
eqs = [
    D(temp) ~ furnace_on * furnace_power - temp^2 * leakage
]

# %% 12
using Setfield
furnace_disable = ModelingToolkit.SymbolicContinuousCallback(
    [temp ~ furnace_off_threshold],
    ModelingToolkit.ImperativeAffect(modified = (; furnace_on)) do x, o, c, i
        @set! x.furnace_on = false
    end)
furnace_enable = ModelingToolkit.SymbolicContinuousCallback(
    [temp ~ furnace_on_threshold],
    ModelingToolkit.ImperativeAffect(modified = (; furnace_on)) do x, o, c, i
        @set! x.furnace_on = true
    end)

# %% 13
@named sys = System(
    eqs, t, [temp], params; continuous_events = [furnace_disable, furnace_enable])
ss = mtkcompile(sys)
prob = ODEProblem(ss, [temp => 0.0, furnace_on => true], (0.0, 10.0))
sol = solve(prob, Tsit5())
plot(sol)
hline!([sol.ps[furnace_off_threshold], sol.ps[furnace_on_threshold]],
    l = (:black, 1), primary = false)

# %% 14
@variables theta(t) omega(t)
params = @parameters qA=0 qB=0 hA=0 hB=0 cnt::Int=0
eqs = [D(theta) ~ omega
       omega ~ 1.0]

# %% 15
function decoder(oldA, oldB, newA, newB)
    state = (oldA, oldB, newA, newB)
    if state == (0, 0, 1, 0) || state == (1, 0, 1, 1) || state == (1, 1, 0, 1) ||
       state == (0, 1, 0, 0)
        return 1
    elseif state == (0, 0, 0, 1) || state == (0, 1, 1, 1) || state == (1, 1, 1, 0) ||
           state == (1, 0, 0, 0)
        return -1
    elseif state == (0, 0, 0, 0) || state == (0, 1, 0, 1) || state == (1, 0, 1, 0) ||
           state == (1, 1, 1, 1)
        return 0
    else
        return 0 # err is interpreted as no movement
    end
end

# %% 16
qAevt = ModelingToolkit.SymbolicContinuousCallback([cos(100 * theta) ~ 0],
    ModelingToolkit.ImperativeAffect((; qA, hA, hB, cnt), (; qB)) do x, o, c, i
        @set! x.hA = x.qA
        @set! x.hB = o.qB
        @set! x.qA = 1
        @set! x.cnt += decoder(x.hA, x.hB, x.qA, o.qB)
        x
    end,
    affect_neg = ModelingToolkit.ImperativeAffect(
        (; qA, hA, hB, cnt), (; qB)) do x, o, c, i
        @set! x.hA = x.qA
        @set! x.hB = o.qB
        @set! x.qA = 0
        @set! x.cnt += decoder(x.hA, x.hB, x.qA, o.qB)
        x
    end)

# %% 17
qBevt = ModelingToolkit.SymbolicContinuousCallback([cos(100 * theta - π / 2) ~ 0],
    ModelingToolkit.ImperativeAffect((; qB, hA, hB, cnt), (; qA, theta)) do x, o, c, i
        @set! x.hA = o.qA
        @set! x.hB = x.qB
        @set! x.qB = clamp(sign(cos(100 * o.theta - π / 2)), 0.0, 1.0)
        @set! x.cnt += decoder(x.hA, x.hB, o.qA, x.qB)
        x
    end; rootfind = SciMLBase.RightRootFind)

# %% 18
@named sys = System(
    eqs, t, [theta, omega], params; continuous_events = [qAevt, qBevt])
ss = mtkcompile(sys)
prob = ODEProblem(ss, [theta => 0.0], (0.0, pi))
sol = solve(prob, Tsit5(); dtmax = 0.01)
sol.ps[cnt]
