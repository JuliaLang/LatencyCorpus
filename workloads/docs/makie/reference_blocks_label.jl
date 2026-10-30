# env: makie
# kind: unknown
# source: reference/blocks/label.md

# %% prelude
using CairoMakie

# %% 1

fig = Figure()

fig[1:2, 1:3] = [Axis(fig) for _ in 1:6]

supertitle = Label(fig[0, :], "Six plots", fontsize = 30)

sideinfo = Label(fig[1:2, 0], "This text is vertical", rotation = pi/2)

fig

# %% 2

f = Figure()

Label(f[1, 1],
    "Multiline label\nwith\njustification = :left\nand\nlineheight = 0.9",
    justification = :left,
    lineheight = 0.9
)
Label(f[1, 2],
    "Multiline label\nwith\njustification = :center\nand\nlineheight = 1.1",
    justification = :center,
    lineheight = 1.1,
    color = :dodgerblue,
)
Label(f[1, 3],
    "Multiline label\nwith\njustification = :right\nand\nlineheight = 1.3",
    justification = :right,
    lineheight = 1.3,
    color = :firebrick
)

f
