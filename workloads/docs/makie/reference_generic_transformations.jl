# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/generic/transformations.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()
# transform 0..1 Rect to -1..1 Rect
lines(f[1, 1], Rect2f(0, 0, 1, 1),
    transformation = (scale = Vec3f(2), translation = Vec3f(-1)))

a = LScene(f[1, 2])
heatmap!(a, rand(4,4), transformation = (:xy, 0.5))
heatmap!(a, rand(4,4), transformation = (:xz, 0.5))
heatmap!(a, rand(4,4), transformation = (:yz, 0.5))
f
