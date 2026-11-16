# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/tutorials/callable_params.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using OrdinaryDiffEq
using DataInterpolations
using ModelingToolkit: t_nounits as t, D_nounits as D

ts = collect(0.0:0.1:10.0)
spline = LinearInterpolation(ts .^ 2, ts)
Tspline = typeof(spline)
@variables x(t)
@parameters (interp::Tspline)(..)

@mtkcompile sys = System(D(x) ~ interp(t), t)

# %% 2
prob = ODEProblem(sys, [x => 0.0, interp => spline], (0.0, 1.0))
solve(prob)
