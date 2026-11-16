# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/blocks.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()
ax = Axis(f[1, 1])
f

# %% 2
f = Figure()
Axis(f, bbox = BBox(50, 200, 50, 300), title = "Axis 1")
Axis(f, bbox = BBox(250, 550, 100, 350), title = "Axis 2")
f
