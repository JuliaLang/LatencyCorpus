# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/tutorials/disturbance_modeling.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit, OrdinaryDiffEq, LinearAlgebra, Test
using ModelingToolkitStandardLibrary.Mechanical.Rotational
using ModelingToolkitStandardLibrary.Blocks
t = ModelingToolkit.t_nounits
D = ModelingToolkit.D_nounits

# Define the SystemModel component
function SystemModel(; name, m1 = 1, m2 = 1, k = 10, c = 3)
    @parameters begin
        m1 = m1
        m2 = m2
        k = k # Spring stiffness
        c = c # Damping coefficient
    end
    systems = @named begin
        inertia1 = Inertia(; J = m1, phi = 0, w = 0)
        inertia2 = Inertia(; J = m2, phi = 0, w = 0)
        spring = Spring(; c = k)
        damper = Damper(; d = c)
        torque = Torque(use_support = false)
    end

    eqs = [
        connect(torque.flange, inertia1.flange_a)
        connect(inertia1.flange_b, spring.flange_a, damper.flange_a)
        connect(inertia2.flange_a, spring.flange_b, damper.flange_b)
    ]

    System(eqs, t, [], [m1, m2, k, c];
        systems,
        name)
end

# %% 2
# Define a model with inputs
function ModelWithInputs(; name)
    systems = @named begin
        input_signal = Blocks.Sine(frequency = 1, amplitude = 1)
        disturbance_signal1 = Blocks.Step(height = -1, start_time = 2) # We add an input signal that equals zero by default so that it has no effect during normal simulation
        disturbance_signal2 = Blocks.Step(height = 2, start_time = 4)
        disturbance_torque1 = Torque(use_support = false)
        disturbance_torque2 = Torque(use_support = false)
        system_model = SystemModel()
    end

    eqs = [
        connect(input_signal.output, :u, system_model.torque.tau)
        connect(disturbance_signal1.output, :d1, disturbance_torque1.tau) # When we connect the input _signals_, we do so through an analysis point. This allows us to easily disconnect the input signals in situations when we do not need them.
        connect(disturbance_signal2.output, :d2, disturbance_torque2.tau)
        connect(disturbance_torque1.flange, system_model.inertia1.flange_b)
        connect(disturbance_torque2.flange, system_model.inertia2.flange_b)
    ]

    System(eqs, t;
        systems,
        name)
end

# %% 3
@named model = ModelWithInputs() # Model with load disturbance
ssys = mtkcompile(model)
prob = ODEProblem(ssys, [], (0.0, 6.0))
sol = solve(prob, Tsit5())
using Plots
plot(sol)

# %% 4
# pruned: failed without tiering
# %% 5
# Define an integrating disturbance model
function IntegratingDisturbance(; name)
    @variables x(t) = 0.0 w(t) = 0.0 [disturbance = true, input = true]
    systems = @named begin
        input = RealInput()
        output = RealOutput()
    end
    eqs = [
        D(x) ~ w
        w ~ input.u
        output.u ~ x
    ]
    System(eqs, t, [x, w], []; systems, name)
end

# Define a system model with disturbance model
function SystemModelWithDisturbanceModel(; name)
    systems = @named begin
        input_signal = Blocks.Sine(frequency = 1, amplitude = 1)
        disturbance_signal1 = Blocks.Constant(k = 0)
        disturbance_signal2 = Blocks.Constant(k = 0)
        disturbance_torque1 = Torque(use_support = false)
        disturbance_torque2 = Torque(use_support = false)
        disturbance_model = Blocks.Integrator()
        system_model = SystemModel()
    end

    eqs = [
        connect(input_signal.output, :u, system_model.torque.tau)
        connect(disturbance_signal1.output, :d1, disturbance_model.input)
        connect(disturbance_model.output, disturbance_torque1.tau)
        connect(disturbance_signal2.output, :d2, disturbance_torque2.tau)
        connect(disturbance_torque1.flange, system_model.inertia1.flange_b)
        connect(disturbance_torque2.flange, system_model.inertia2.flange_b)
    ]

    System(eqs, t;
        systems,
        name)
end

@named model_with_disturbance = SystemModelWithDisturbanceModel()

# %% 6
ssys = mtkcompile(model_with_disturbance)
prob = ODEProblem(ssys, [], (0.0, 10.0))
sol = solve(prob, Tsit5())
using Test
@test SciMLBase.successful_retcode(sol)
