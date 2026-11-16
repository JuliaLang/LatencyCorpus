# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/backends/cairomakie.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
v = rand(10,2)
scatter(v[:,1], v[:,2], rasterize = true, markersize = 30.0)

# %% 2
v = rand(10,2)
scatter(v[:,1], v[:,2], rasterize = 10, markersize = 30.0)
