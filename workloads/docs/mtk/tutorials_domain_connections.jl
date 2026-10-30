# env: sciml
# kind: unknown
# source: tutorials/domain_connections.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@connector function HydraulicPort(; p_int, name)
    pars = @parameters begin
        ρ
        β
        μ
    end

    vars = @variables begin
        p(t) = p_int
        dm(t), [connect = Flow]
    end

    System(Equation[], t, vars, pars; name, bindings = [dm => 0])
end
nothing #hide

# %% 2
@connector function HydraulicFluid(;
        density = 997,
        bulk_modulus = 2.09e9,
        viscosity = 0.0010016,
        name)
    pars = @parameters begin
        ρ = density
        β = bulk_modulus
        μ = viscosity
    end

    vars = @variables begin
        dm(t), [connect = Flow]
    end

    eqs = [
        dm ~ 0
    ]

    System(eqs, t, vars, pars; name, bindings = [dm => 0])
end
nothing #hide

# %% 3
@component function FixedPressure(; p, name)
    pars = @parameters p = p
    systems = @named begin
        port = HydraulicPort(; p_int = p)
    end

    eqs = [port.p ~ p]

    System(eqs, t, [], pars; name, systems)
end

@component function FixedVolume(; vol, p_int, name)
    pars = @parameters begin
        p_int = p_int
        vol = vol
    end

    systems = @named begin
        port = HydraulicPort(; p_int)
    end

    vars = @variables begin
        rho(t) = port.ρ
        drho(t) = 0
    end

    # let
    dm = port.dm
    p = port.p

    eqs = [D(rho) ~ drho
           rho ~ port.ρ * (1 + p / port.β)
           dm ~ drho * vol]

    System(eqs, t, vars, pars; name, systems)
end
nothing #hide

# %% 4
@component function HydraulicSystem(; name)
    systems = @named begin
        src = FixedPressure(; p = 200e5)
        vol = FixedVolume(; vol = 0.1, p_int = 200e5)

        fluid = HydraulicFluid(; density = 876)
    end

    eqs = [connect(fluid, src.port)
           connect(src.port, vol.port)]

    System(eqs, t, [], []; systems, name)
end

@named odesys = HydraulicSystem()
nothing #hide

# %% 5
sys = mtkcompile(odesys)

# %% 6
ModelingToolkit.bindings(sys)[sys.vol.port.ρ]

# %% 7
@component function Actuator(; p_int, mass, area, name)
    pars = @parameters begin
        p_int = p_int
        mass = mass
        area = area
    end

    systems = @named begin
        port_a = HydraulicPort(; p_int)
        port_b = HydraulicPort(; p_int)
    end

    vars = @variables begin
        x(t) = 0
        dx(t) = 0
        ddx(t) = 0
    end

    eqs = [D(x) ~ dx
           D(dx) ~ ddx
           mass * ddx ~ (port_a.p - port_b.p) * area
           port_a.dm ~ +(port_a.ρ) * dx * area
           port_b.dm ~ -(port_b.ρ) * dx * area]

    System(eqs, t, vars, pars; name, systems)
end
nothing #hide

# %% 8
@component function ActuatorSystem2(; name)
    systems = @named begin
        src_a = FixedPressure(; p = 200e5)
        src_b = FixedPressure(; p = 200e5)
        act = Actuator(; p_int = 200e5, mass = 1000, area = 0.1)

        fluid_a = HydraulicFluid(; density = 876)
        fluid_b = HydraulicFluid(; density = 999)
    end

    eqs = [connect(fluid_a, src_a.port)
           connect(fluid_b, src_b.port)
           connect(src_a.port, act.port_a)
           connect(src_b.port, act.port_b)]

    System(eqs, t, [], []; systems, name)
end

@named actsys2 = ActuatorSystem2()
nothing #hide

# %% 9
@component function ActuatorSystem1(; name)
    systems = @named begin
        src_a = FixedPressure(; p = 200e5)
        src_b = FixedPressure(; p = 200e5)
        act = Actuator(; p_int = 200e5, mass = 1000, area = 0.1)

        fluid = HydraulicFluid(; density = 876)
    end

    eqs = [connect(fluid, src_a.port)
           connect(fluid, src_b.port)
           connect(src_a.port, act.port_a)
           connect(src_b.port, act.port_b)]

    System(eqs, t, [], []; systems, name)
end

@named actsys1 = ActuatorSystem1()
nothing #hide

# %% 10
@component function Restrictor(; name, p_int)
    pars = @parameters begin
        K = 0.1
        p_int = p_int
    end

    systems = @named begin
        port_a = HydraulicPort(; p_int)
        port_b = HydraulicPort(; p_int)
    end

    eqs = [port_a.dm ~ (port_a.p - port_b.p) * K
           0 ~ port_a.dm + port_b.dm]

    System(eqs, t, [], pars; systems, name)
end
nothing #hide

# %% 11
@component function RestrictorSystem(; name)
    systems = @named begin
        src = FixedPressure(; p = 200e5)
        res = Restrictor(; p_int = 200e5)
        vol = FixedVolume(; vol = 0.1, p_int = 200e5)

        fluid = HydraulicFluid(; density = 876)
    end

    eqs = [connect(fluid, src.port)
           connect(src.port, res.port_a)
           connect(res.port_b, vol.port)]

    System(eqs, t, [], []; systems, name)
end

@mtkcompile ressys = RestrictorSystem()
nothing #hide

# %% 12
ModelingToolkit.bindings(ressys)[ressys.res.port_a.ρ]

# %% 13
# pruned: failed without tiering
# %% 14
# pruned: failed without tiering
# %% 15
@component function Restrictor(; name, p_int)
    pars = @parameters begin
        K = 0.1
        p_int = p_int
    end

    systems = @named begin
        port_a = HydraulicPort(; p_int)
        port_b = HydraulicPort(; p_int)
    end

    eqs = [domain_connect(port_a, port_b) # <-- connect the domain network
           port_a.dm ~ (port_a.p - port_b.p) * K
           0 ~ port_a.dm + port_b.dm]

    System(eqs, t, [], pars; systems, name)
end

@mtkcompile ressys = RestrictorSystem()
nothing #hide

# %% 16
ModelingToolkit.bindings(ressys)[ressys.res.port_a.ρ]

# %% 17
ModelingToolkit.bindings(ressys)[ressys.res.port_b.ρ]

# %% 18
ModelingToolkit.bindings(ressys)[ressys.vol.port.ρ]
