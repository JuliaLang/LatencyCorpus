# env: makie
# kind: interactive
# source: tutorials/pixel-perfect-rendering.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie

data = [1 2; 3 4; 5 6]

f = Figure()

a1, p = image(f[1, 1], data)
a2, p = heatmap(f[1, 2], data)

# 0..3, 0..2 is the default, we could omit it
a3, p = image(f[2, 1], 0..3, 0..2, data, colormap = :viridis, interpolate = false)
a4, p = heatmap(f[2, 2], 0:3, 0:2, data, colormap = :viridis, interpolate = false)
# Note that length(0:3), length(0:2) == size(data) .+ 1

limits!.([a1, a2, a3, a4], -1, 4, -1, 3)

f

# %% 2
using CairoMakie

scene = Scene(size = (200, 100), camera = campixel!)

# %% 3
using CairoMakie

data = [ifelse(x > 180, 0, x/100) * ifelse(y > 80, 0, y/50) for x in 1:200, y in 1:100]

scene = Scene(size = (200, 100), camera = campixel!)

# image will have the correct limits by default (0..200, 0..100)
image!(scene, data, colormap = :viridis, interpolate = false)

# alternatively with heatmap:
# heatmap!(scene, 0:200, 0:100, data)

scene

# %% 4
using CairoMakie

data = [ifelse(x > 180, 0, x/100) * ifelse(y > 80, 0, y/50) for x in 1:200, y in 1:100]
scene = Scene(size = (3 * 200, 2 * 100), camera = campixel!)
image!(scene, 0..600, 0..200, data, colormap = :viridis, interpolate = false)
# heatmap!(scene, 0:3:600, 0:2:200, data)

scene

# %% 5
using CairoMakie

data = [ifelse(x > 180, 0, x/100) * ifelse(y > 80, 0, y/50) for x in 1:200, y in 1:100]
scene = Scene(size = (3 * 200, 2 * 100))
image!(scene, -1..1, -1..1, data, colormap = :viridis, interpolate = false)
scene

# %% 6
using CairoMakie

# length(50:50) = 101
data = [x*y/1000 for x in -50:50, y in -50:50]

fig = Figure()

s1 = LScene(fig[1, 1], width = 101, height = 101, show_axis = false, scenekw = (camera = cam_relative!,))
image!(s1, 0..1, 0..1, data, colormap = :viridis, interpolate = false)

s2 = LScene(fig[1, 2], width = 101, height = 101, show_axis = false, scenekw = (camera = campixel!,))
heatmap!(s2, 0:101, 0:101, data)

resize_to_layout!(fig)
fig

# %% 7
using CairoMakie

# length(50:50) = 101
data = [x*y/1000 for x in -50:50, y in -50:50]

fig = Figure()

a1 = Axis(fig[1, 1], width = 101, height = 101)
image!(a1, data, colormap = :viridis, interpolate = false)

a2 = Axis(fig[1, 2], width = 101, height = 101)
heatmap!(a2, data)

resize_to_layout!(fig)
fig
