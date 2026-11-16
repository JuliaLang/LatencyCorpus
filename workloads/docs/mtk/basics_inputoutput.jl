# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/basics/InputOutput.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
import ModelingToolkit: t_nounits as t, D_nounits as D
@variables x(t)=0 u(t)=0 y(t)
@parameters k = 1
eqs = [D(x) ~ -k * (x + u)
       y ~ x]

@named sys = System(eqs, t)
(; f, dvs, ps, io_sys) = ModelingToolkit.generate_control_function(
    sys, [u]; simplify = true
)
nothing # hide

# %% 2
dvs

# %% 3
using Test # hide
@test isequal(dvs[], x) # hide
@test isequal(ps, [k]) # hide
nothing  # hide

# %% 4
p = [1]
x_val = [rand()]
u_val = [rand()]
@test f[1](x_val, u_val, p, 1) ≈ -p[] * (x_val + u_val)

# %% 5
g = ModelingToolkit.build_explicit_observed_function(io_sys, [x + u * t]; inputs = [u])
@test g([1.0], [2.0], p, 3.0) ≈ [7.0]
