# env: sciml
# kind: unknown
# source: tutorials/bifurcation_diagram_computation.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables x(t) y(t)
@parameters μ α
eqs = [0 ~ μ * x - x^3 + α * y,
    0 ~ -y]
@mtkcompile nsys = System(eqs, [x, y], [μ, α])

# %% 2
bif_par = μ
p_start = [μ => -1.0, α => 1.0]
u0_guess = [x => 1.0, y => 1.0]
plot_var = x;

# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
# %% 8
# pruned: failed without tiering
# %% 9
# pruned: failed without tiering
