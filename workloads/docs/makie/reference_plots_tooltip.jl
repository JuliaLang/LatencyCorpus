# env: makie
# kind: interactive
# source: reference/plots/tooltip.md

# %% prelude
using CairoMakie

# %% 1
fig, ax, p = scatter(Point2f(0), marker = 'x', markersize = 20)
tooltip!(Point2f(0), "This is a tooltip pointing at x")
fig
