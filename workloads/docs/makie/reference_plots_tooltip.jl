# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/tooltip.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
fig, ax, p = scatter(Point2f(0), marker = 'x', markersize = 20)
tooltip!(Point2f(0), "This is a tooltip pointing at x")
fig
