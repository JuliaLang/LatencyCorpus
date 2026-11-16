# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/faq.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()

ax1 = Axis(f, title = "Squashed")
ax2 = Axis(f[1, 1], title = "Placed in Layout")
ax3 = Axis(f, bbox = BBox(200, 600, 100, 500),
  title = "Placed at BBox(200, 600, 100, 500)")

f

# %% 2
f = Figure()

Axis(f[1, 1], title = "Shrunk")
Axis(f[2, 1], title = "Expanded")
Label(f[1, 2], "This Label has the setting\ntellheight = true\ntherefore the row it is in has\nadjusted to match its height.", tellheight = true)
Label(f[2, 2], "This Label has the setting\ntellheight = false.\nThe row it is in can use\nall the remaining space.", tellheight = false)

f

# %% 3
set_theme!(backgroundcolor = :gray90)

f = Figure(size = (800, 600))

for i in 1:3, j in 1:3
    ax = Axis(f[i, j], title = "$i, $j", width = 100, height = 100)
    i < 3 && hidexdecorations!(ax, grid = false)
    j > 1 && hideydecorations!(ax, grid = false)
end

Colorbar(f[1:3, 4])

f

# %% 4
resize_to_layout!(f)
set_theme!() # hide
f
