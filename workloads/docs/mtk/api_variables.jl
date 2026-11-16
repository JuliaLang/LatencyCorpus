# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/API/variables.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
@variables u [description = "This is my input"]
getdescription(u)

# %% 2
@variables u(t) [description = "A short description of u"]
@parameters p [description = "A description of p"]
@named sys = System([u ~ p], t)
show(stdout, "text/plain", sys) # hide

# %% 3
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables i(t) [connect = Flow]
@variables k(t) [connect = Stream]
hasconnect(i)

# %% 4
getconnect(k)

# %% 5
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables u [input = true]
isinput(u)

# %% 6
@variables y [output = true]
isoutput(y)

# %% 7
@variables u [bounds = (-1, 1)];

# %% 8
hasbounds(u)

# %% 9
getbounds(u)

# %% 10
@variables x[1:2, 1:2] [bounds = (-1, 1)];

# %% 11
hasbounds(x)

# %% 12
getbounds(x)

# %% 13
getbounds(x[1, 1])

# %% 14
getbounds(x[1:2, 1])

# %% 15
@variables x[1:2] [bounds = (-Inf, [1.0, Inf])];

# %% 16
hasbounds(x)

# %% 17
getbounds(x)

# %% 18
getbounds(x[2])

# %% 19
hasbounds(x[2])

# %% 20
@variables x [nominal = 1000.0];

# %% 21
hasnominal(x)

# %% 22
getnominal(x)

# %% 23
@variables x[1:3] [nominal = [100.0, 200.0, 300.0]];

# %% 24
getnominal(x)

# %% 25
getnominal(x[1])

# %% 26
@variables u [guess = 1];

# %% 27
hasguess(u)

# %% 28
getguess(u)

# %% 29
@variables u [input = true, disturbance = true]
isdisturbance(u)

# %% 30
@parameters Kp [tunable = true]
istunable(Kp)

# %% 31
using Distributions;

# %% 32
d = Normal(10, 1);

# %% 33
@parameters m [dist = d];

# %% 34
hasdist(m)

# %% 35
getdist(m)

# %% 36
@variables important_value [irreducible = true]
isirreducible(important_value)

# %% 37
@variables important_dof [state_priority = 10] unimportant_dof [state_priority = -2]
state_priority(important_dof)

# %% 38
using DynamicQuantities;

# %% 39
@variables speed [unit = u"m/s"];

# %% 40
hasunit(speed)

# %% 41
getunit(speed)

# %% 42
@variables u [misc = :conserved_parameter] y [misc = [2, 4, 6]];

# %% 43
hasmisc(u)

# %% 44
getmisc(y)

# %% 45
@variables x(t)=0 u(t)=0 [input=true] y(t)=0 [output=true]
@parameters T [tunable = true, bounds = (0, Inf)]
@parameters k [tunable = true, bounds = (0, Inf)]
eqs = [D(x) ~ (-x + k * u) / T # A first-order system with time constant T and gain k
       y ~ x]
sys = System(eqs, t, name = :tunable_first_order)

# %% 46
p = tunable_parameters(sys) # extract all parameters marked as tunable

# %% 47
lb, ub = getbounds(p) # operating on a vector, we get lower and upper bound vectors

# %% 48
b = getbounds(sys) # Operating on the system, we get a dict
