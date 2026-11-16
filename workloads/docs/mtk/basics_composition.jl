# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/basics/Composition.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

function decay(; name)
    @parameters a
    @variables x(t) f(t)
    System([
            D(x) ~ -a * x + f
        ], t;
        name = name)
end

@named decay1 = decay()
@named decay2 = decay()

connected = compose(
    System([decay2.f ~ decay1.x
            D(decay1.f) ~ 0], t; name = :connected), decay1, decay2)

equations(connected)

#4-element Vector{Equation}:
# Differential(t)(decay1₊f(t)) ~ 0
# decay2₊f(t) ~ decay1₊x(t)
# Differential(t)(decay1₊x(t)) ~ decay1₊f(t) - (decay1₊a*(decay1₊x(t)))
# Differential(t)(decay2₊x(t)) ~ decay2₊f(t) - (decay2₊a*(decay2₊x(t)))

simplified_sys = mtkcompile(connected)

equations(simplified_sys)

# %% 2
x0 = [decay1.x => 1.0
      decay1.f => 0.0
      decay2.x => 1.0]
p = [decay1.a => 0.1
     decay2.a => 0.2]

using OrdinaryDiffEq
prob = ODEProblem(simplified_sys, [x0; p], (0.0, 100.0))
sol = solve(prob, Tsit5())
sol[decay2.f]

# %% 3
using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkit: t_nounits as t, D_nounits as D

## Library code
@variables S(t), I(t), R(t)
N = S + I + R
@parameters β, γ

@named seqn = System([D(S) ~ -β * S * I / N], t)
@named ieqn = System([D(I) ~ β * S * I / N - γ * I], t)
@named reqn = System([D(R) ~ γ * I], t)

sir = compose(
    System(
        [
            S ~ ieqn.S,
            I ~ seqn.I,
            R ~ ieqn.R,
            ieqn.S ~ seqn.S,
            seqn.I ~ ieqn.I,
            seqn.R ~ reqn.R,
            ieqn.R ~ reqn.R,
            reqn.I ~ ieqn.I],
        t,
        [S, I, R],
        [β, γ],
        bindings = [seqn.β => β
                    ieqn.β => β
                    ieqn.γ => γ
                    reqn.γ => γ], name = :sir),
    seqn,
    ieqn,
    reqn)

# %% 4
sireqn_simple = mtkcompile(sir)

equations(sireqn_simple)

# %% 5
## User Code

u0 = [seqn.S => 990.0,
    ieqn.I => 10.0,
    reqn.R => 0.0]

p = [β => 0.5
     γ => 0.25]

tspan = (0.0, 40.0)
prob = ODEProblem(sireqn_simple, u0, tspan, p, jac = true)
sol = solve(prob, Tsit5())
sol[reqn.R]
