# env: makie
# kind: unknown
# source: reference/plots/ablines.md

# %% prelude
using CairoMakie

# %% 1
ablines(0, 1)
ablines!([1, 2, 3], [1, 1.5, 2], color = [:red, :orange, :pink], linestyle=:dash, linewidth=2)
current_figure()
