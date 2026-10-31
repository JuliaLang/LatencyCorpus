# env: sciml
# kind: overcompile
# source: tutorials/acausal_components.md

# %% 1
using ModelingToolkit, Plots, OrdinaryDiffEq, Setfield
using ModelingToolkit: t_nounits as t, D_nounits as D

# Define the Pin connector
function Pin(; name)
    @variables v(t) i(t) [connect = Flow]
    sys = System(Equation[], t, [v, i], []; name)
    sys = @set sys.connector_type = ModelingToolkit.connector_type(sys)
    return sys
end

# Define Ground component
function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0]
    System(eqs, t, [], []; systems = [g], name)
end

# Define OnePort base component
function OnePort(; name)
    @named p = Pin()
    @named n = Pin()
    @variables v(t) i(t)
    eqs = [
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    ]
    System(eqs, t, [v, i], []; systems = [p, n], name)
end

# Define Resistor component
function Resistor(; name, R = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @parameters R = R # Sets the default resistance
    eqs = [v ~ i * R]
    extend(System(eqs, t, [], [R]; name), oneport)
end

# Define Capacitor component
function Capacitor(; name, C = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @parameters C = C
    eqs = [D(v) ~ i / C]
    extend(System(eqs, t, [], [C]; name), oneport)
end

# Define ConstantVoltage source
function ConstantVoltage(; name, V = 1.0)
    @named oneport = OnePort()
    @unpack v = oneport
    @parameters V = V
    eqs = [V ~ v]
    extend(System(eqs, t, [], [V]; name), oneport)
end

# Build the RC circuit
@named resistor = Resistor(R = 2.0)
@named capacitor = Capacitor(C = 1.0)
@named source = ConstantVoltage(V = 1.0)
@named ground = Ground()

rc_eqs = [
    connect(source.p, resistor.p)
    connect(resistor.n, capacitor.p)
    connect(capacitor.n, source.n)
    connect(capacitor.n, ground.g)
]

@named rc_model = System(rc_eqs, t; systems = [resistor, capacitor, source, ground])
rc_model = mtkcompile(rc_model)

u0 = [
    rc_model.capacitor.v => 0.0
]
prob = ODEProblem(rc_model, u0, (0, 10.0))
sol = solve(prob)
plot(sol)

# %% 2
function Pin(; name)
    @variables v(t) i(t) [connect = Flow]
    sys = System(Equation[], t, [v, i], []; name)
    sys = @set sys.connector_type = ModelingToolkit.connector_type(sys)
    return sys
end

# %% 3
@named mypin1 = Pin()

# %% 4
function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0]
    System(eqs, t, [], []; systems = [g], name)
end

# %% 5
function OnePort(; name)
    @named p = Pin()
    @named n = Pin()
    @variables v(t) i(t)
    eqs = [
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    ]
    System(eqs, t, [v, i], []; systems = [p, n], name)
end

# %% 6
function Resistor(; name, R = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @parameters R = R # Sets the default resistance
    eqs = [v ~ i * R]
    extend(System(eqs, t, [], [R]; name), oneport)
end

# %% 7
function Capacitor(; name, C = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @parameters C = C
    eqs = [D(v) ~ i / C]
    extend(System(eqs, t, [], [C]; name), oneport)
end

# %% 8
function ConstantVoltage(; name, V = 1.0)
    @named oneport = OnePort()
    @unpack v = oneport
    @parameters V = V
    eqs = [V ~ v]
    extend(System(eqs, t, [], [V]; name), oneport)
end

# %% 9
@named resistor = Resistor(R = 2.0)
@named capacitor = Capacitor(C = 1.0)
@named source = ConstantVoltage(V = 1.0)
@named ground = Ground()

rc_eqs = [
    connect(source.p, resistor.p)
    connect(resistor.n, capacitor.p)
    connect(capacitor.n, source.n)
    connect(capacitor.n, ground.g)
]

@named rc_model = System(rc_eqs, t; systems = [resistor, capacitor, source, ground])
rc_model = mtkcompile(rc_model)

# %% 10
equations(expand_connections(rc_model))

# %% 11
unknowns(rc_model)

# %% 12
parameters(rc_model)

# %% 13
observed(rc_model)

# %% 14
u0 = [rc_model.capacitor.v => 0.0]

prob = ODEProblem(rc_model, u0, (0, 10.0))
sol = solve(prob)
plot(sol)

# %% 15
observed(rc_model)

# %% 16
sol[rc_model.resistor.v]

# %% 17
plot(sol, idxs = [rc_model.resistor.v])

# %% 18
plot(sol, idxs = [unknowns(rc_model); observables(rc_model)])
