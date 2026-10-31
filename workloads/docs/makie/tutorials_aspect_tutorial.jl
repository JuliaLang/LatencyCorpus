# env: makie
# kind: interactive
# source: tutorials/aspect-tutorial.md

# %% prelude
using CairoMakie

# %% 1
set_theme!(backgroundcolor = :gray90)

f = Figure(size = (800, 500))
ax = Axis(f[1, 1], aspect = 1)
Colorbar(f[1, 2])
f

# %% 2
Box(f[1, 1], color = (:red, 0.2), strokewidth = 0)
f

# %% 3
f = Figure(size = (800, 500))
ax = Axis(f[1, 1])
Colorbar(f[1, 2])
colsize!(f.layout, 1, Aspect(1, 1.0))
f

# %% 4
# hide
Box(f[1, 1], color = (:red, 0.2), strokewidth = 0)
f

# %% 5
ax.aspect = 0.5
f

# %% 6
colsize!(f.layout, 1, Aspect(1, 0.5))
f

# %% 7
# hide
f = Figure(size = (800, 500))
ax = Axis(f[1, 1])
Colorbar(f[1, 2])
colsize!(f.layout, 1, Aspect(1, 1.0))
f

# %% 8
resize_to_layout!(f)
f

# %% 9
f = Figure()
for i in 1:5, j in 1:5
    Axis(f[i, j], width = 150, height = 150)
end
f

# %% 10
set_theme!() # hide
resize_to_layout!(f)
f
