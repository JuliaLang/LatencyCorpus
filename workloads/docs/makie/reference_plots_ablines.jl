# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/ablines.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
ablines(0, 1)
ablines!([1, 2, 3], [1, 1.5, 2], color = [:red, :orange, :pink], linestyle=:dash, linewidth=2)
current_figure()
