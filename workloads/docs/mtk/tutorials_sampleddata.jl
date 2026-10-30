# env: sciml
# kind: unknown
# source: tutorials/SampledData.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t
@variables x(t) y(t) u(t)
dt = 0.1                # Sample interval
clock = Clock(dt)    # A periodic clock with tick rate dt
k = ShiftIndex(clock)

eqs = [
    x(k) ~ 0.5x(k - 1) + u(k - 1),
    y ~ x
]

# %% 2
eqs = [
    x(k + 1) ~ 0.5x(k) + u(k),
    y(k) ~ x(k)
]

# %% 3
eqs = [
    x(k) ~ 0.5x(k - 1) + u(k),
    y ~ x
]

# %% 4
using ModelingToolkit, Plots, OrdinaryDiffEq
using ModelingToolkit: t_nounits as t
using ModelingToolkit: D_nounits as D
dt = 0.5 # Sample interval
@variables r(t)
clock = Clock(dt)
k = ShiftIndex(clock)

function plant(; name)
    @variables x(t)=1 u(t)=0 y(t)=0
    eqs = [D(x) ~ -x + u
           y ~ x]
    System(eqs, t; name = name)
end

function filt(; name) # Reference filter
    @variables x(t)=0 u(t)=0 y(t)=0
    a = 1 / exp(dt)
    eqs = [x(k) ~ a * x(k - 1) + (1 - a) * u(k)
           y ~ x]
    System(eqs, t, name = name)
end

function controller(kp; name)
    @variables y(t)=0 r(t)=0 ud(t)=0 yd(t)=0
    @parameters kp = kp
    eqs = [yd ~ Sample(y)
           ud ~ kp * (r - yd)]
    System(eqs, t; name = name)
end

@named f = filt()
@named c = controller(1)
@named p = plant()

connections = [r ~ sin(t)          # reference signal
               f.u ~ r             # reference to filter input
               f.y ~ c.r           # filtered reference to controller reference
               Hold(c.ud) ~ p.u    # controller output to plant input (zero-order-hold)
               p.y ~ c.y]          # plant output to controller feedback

@named cl = System(connections, t, systems = [f, c, p])
