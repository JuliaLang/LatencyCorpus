# env: sciml
# kind: unknown
# source: API/abstract_system_interface.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

struct ComponentSystem <: ModelingToolkit.AbstractSystem
    eqs::Vector{Equation}
    unknowns::Vector
    ps::Vector
    iv::Any
    name::Symbol
    systems::Vector
end

@variables x(t) y(t)
@parameters p q

leaf = ComponentSystem([D(x) ~ p * x], [x], [p], t, :leaf, [])
root = ComponentSystem([D(y) ~ q * y], [y], [q], t, :root, [leaf])

equations(root)

# %% 2
unknowns(root), ModelingToolkit.unknowns_toplevel(root)

# %% 3
ModelingToolkit.has_iv(root), ModelingToolkit.has_observed(root)
