# env: makie
# kind: unknown
# source: explanations/blocks.md

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
