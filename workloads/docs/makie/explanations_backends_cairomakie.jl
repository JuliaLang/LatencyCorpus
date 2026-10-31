# env: makie
# kind: interactive
# source: explanations/backends/cairomakie.md

# %% prelude
using CairoMakie

# %% 1
v = rand(10,2)
scatter(v[:,1], v[:,2], rasterize = true, markersize = 30.0)

# %% 2
v = rand(10,2)
scatter(v[:,1], v[:,2], rasterize = 10, markersize = 30.0)
