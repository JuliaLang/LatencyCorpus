# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/how-to/draw-boxes-around-subfigures.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()

g1 = GridLayout(f[1, 1], alignmode = Outside(15))
g2 = GridLayout(f[1, 2], alignmode = Outside(15))
box1 = Box(f[1, 1], cornerradius = 10, color = (:tomato, 0.5), strokecolor = :transparent)
box2 = Box(f[1, 2], cornerradius = 10, color = (:teal, 0.5), strokecolor = :transparent)

# move the boxes back so the Axis background polys are in front of them
Makie.translate!(box1.blockscene, 0, 0, -100)
Makie.translate!(box2.blockscene, 0, 0, -100)

Axis(g1[1, 1], backgroundcolor = :white)
Axis(g1[2, 1], backgroundcolor = :white)

Axis(g2[1, 1], backgroundcolor = :white)
Axis(g2[1, 2], backgroundcolor = :white)
Axis(g2[2, 1:2], backgroundcolor = :white)

Label(f[0, :], "Two boxes indicate groups of axes that belong together")

f

# %% 2
using Random # hide
Random.seed!(1234) # hide
f = Figure()

for i in 1:3, j in 1:4
    Axis(f[i, j], title = "$i & $j")
    lines!(cumsum(randn(100)), color = :gray80)
end

b = Box(
    f[1:2, 1:3, Makie.GridLayoutBase.Outer()],
    alignmode = Outside(-5, -12, -8, -5),
    cornerradius = 4,
    color = (:tomato, 0.1),
    strokecolor = :tomato,
    strokewidth = 2,
)
translate!(b.blockscene, 0, 0, -200)

b2 = Box(
    f[2:3, 3:4, Makie.GridLayoutBase.Outer()],
    alignmode = Outside(-5, -12, -8, -5),
    cornerradius = 4,
    color = (:teal, 0.1),
    strokecolor = :teal,
    strokewidth = 2,
)
translate!(b2.blockscene, 0, 0, -200)

Legend(
    f[end+1, :],
    [LineElement(color = :tomato), LineElement(color = :teal)],
    ["Group 1", "Group 2"],
    framevisible = false,
    orientation = :horizontal)
f
