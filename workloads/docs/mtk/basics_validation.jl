# env: sciml
# kind: unknown
# source: basics/Validation.md

# %% 1
using ModelingToolkit, DynamicQuantities
@independent_variables t [unit = u"s"]
@variables x(t) [unit = u"m"] g(t) w(t) [unit = u"Hz"]

@parameters(t, [unit = u"s"])
@variables(x(t), [unit = u"m"], g(t), w(t), [unit = u"Hz"])

@parameters begin
    t, [unit = u"s"]
end
@variables(begin
    x(t), [unit = u"m"],
    g(t),
    w(t), [unit = u"Hz"]
end)

# Simultaneously set default value (use plain numbers, not quantities)
@variables x=10 [unit = u"m"]

# Symbolic array: unit applies to all elements
@variables x[1:3] [unit = u"m"]

# %% 2
using ModelingToolkit, DynamicQuantities
@independent_variables t [unit = u"ms"]
@parameters τ [unit = u"ms"]
@variables E(t) [unit = u"kJ"] P(t) [unit = u"MW"]
D = Differential(t)
eqs = [D(E) ~ P - E / τ,
    0 ~ P]
ModelingToolkit.validate(eqs)

# %% 3
ModelingToolkit.validate(eqs[1])

# %% 4
try
    ModelingToolkit.get_unit(eqs[1].rhs)
catch e
    showerror(stdout, e)
end

# %% 5
using ModelingToolkit, DynamicQuantities
@independent_variables t [unit = u"ms"]
@parameters τ [unit = u"ms"]
@variables E(t) [unit = u"J"] P(t) [unit = u"MW"]
D = Differential(t)
eqs = [D(E) ~ P - E / τ,
    0 ~ P]
ModelingToolkit.validate(eqs) #Returns false while displaying a warning message

# %% 6
using ModelingToolkit, DynamicQuantities
using ModelingToolkit: t_nounits as t, D_nounits as D
# Composite type parameter in registered function
struct NewType
    f::Any
end
@register_symbolic dummycomplex(complex::Num, scalar)
dummycomplex(complex, scalar) = complex.f - scalar

c = NewType(1)
ModelingToolkit.get_unit(x::NewType) = ModelingToolkit.get_unit(x.f)
function ModelingToolkit.get_unit(op::typeof(dummycomplex), args)
    argunits = ModelingToolkit.get_unit.(args)
    ModelingToolkit.get_unit(-, args)
end

sts = @variables a(t)=0 [unit = u"cm"]
ps = @parameters s=-1 [unit=u"cm"] c=c [unit=u"cm"]
eqs = [D(a) ~ dummycomplex(c, s);]
sys = System(
    eqs, t, [sts...;], [ps...;], name = :sys, checks = ~ModelingToolkit.CheckUnits)
sys_simple = mtkcompile(sys)

# %% 7
using ModelingToolkit, DynamicQuantities
@independent_variables t [unit = u"ms"]
@parameters τ [unit = u"ms"]
@variables E(t) [unit = u"kJ"] P(t) [unit = u"MW"]
D = Differential(t)
eqs = [D(E) ~ P - E / τ]
ModelingToolkit.validate(eqs) #Returns true

# %% 8
myfunc(E, τ) = E / τ
eqs = [D(E) ~ P - myfunc(E, τ)]
ModelingToolkit.validate(eqs) #Returns true
