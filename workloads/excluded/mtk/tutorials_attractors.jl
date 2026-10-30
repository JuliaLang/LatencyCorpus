# env: sciml
# kind: unknown
# source: tutorials/attractors.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables x(t)=-4.0 y(t)=5.0 z(t)=0.0
@parameters a=5.0 b=0.1

eqs = [
    D(x) ~ y - x,
    D(y) ~ -x * z + b * abs(z),
    D(z) ~ x * y - a
]

# %% 2
@named modlorenz = System(eqs, t)
ssys = mtkcompile(modlorenz)
# The timespan given to the problem is irrelevant for DynamicalSystems.jl
prob = ODEProblem(ssys, [], (0.0, 1.0))

# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
grid = (
    range(-15.0, 15.0; length = 150), # x
    range(-20.0, 20.0; length = 150), # y
    range(-20.0, 20.0; length = 150) # z
)

# %% 7
# pruned: failed without tiering
# %% 8
# pruned: failed without tiering
# %% 9
# pruned: failed without tiering
# %% 10
# pruned: failed without tiering
# %% 11
# pruned: failed without tiering
# %% 12
# pruned: failed without tiering
# %% 13
ics = [Dict(:x => x, :y => 0, :z => z) for x in grid[1] for z in grid[3]]

# %% 14
# pruned: failed without tiering
# %% 15
# pruned: failed without tiering
# %% 16
# pruned: failed without tiering
# %% 17
# pruned: failed without tiering
# %% 18
params(θ) = [:a => 5 + 0.5cos(θ), :b => 0.1 + 0.01sin(θ)]
θs = range(0, 2π; length = 101)
pcurve = params.(θs)

# %% 19
# pruned: failed without tiering
# %% 20
# pruned: failed without tiering
# %% 21
# pruned: failed without tiering
