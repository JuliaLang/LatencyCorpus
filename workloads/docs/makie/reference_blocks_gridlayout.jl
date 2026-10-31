# env: makie
# kind: interactive
# source: reference/blocks/gridlayout.md

# %% prelude
using CairoMakie

# %% 1

f = Figure()

Axis(f[1, 1], title = "My column has size Fixed(400)")
Axis(f[1, 2], title = "My column has size Auto()")

colsize!(f.layout, 1, Fixed(400))
# colsize!(f.layout, 1, 400) would also work

f

# %% 2

f = Figure()

Axis(f[1, 1], title = "My column has size Relative(2/3)")
Axis(f[1, 2], title = "My column has size Auto()")
Colorbar(f[1, 3])

colsize!(f.layout, 1, Relative(2/3))

f

# %% 3

f = Figure()

Axis(f[1, 1], title = "My column infers my width\nof 200 units")
Axis(f[1, 2], title = "My column gets 1/3rd\nof the remaining space")
Axis(f[1, 3], title = "My column gets 2/3rds\nof the remaining space")

colsize!(f.layout, 2, Auto(1)) # equivalent to Auto(true, 1)
colsize!(f.layout, 3, Auto(2)) # equivalent to Auto(true, 2)

f

# %% 4

f = Figure()

Axis(f[1, 1], title = "I'm square and aligned")
Box(f[1, 2], color = (:blue, 0.1), strokecolor = :transparent)
Axis(f[1, 2], aspect = AxisAspect(1),
    title = "I'm square but break the layout.\nMy actual cell is the blue rect.")
Axis(f[2, 1])
Axis(f[2, 2])

rowsize!(f.layout, 2, Relative(2/3))
colsize!(f.layout, 1, Aspect(1, 1))

f

# %% 5

f = Figure()

subgl_left = GridLayout()
subgl_left[1:2, 1:2] = [Axis(f) for i in 1:2, j in 1:2]

subgl_right = GridLayout()
subgl_right[1:3, 1] = [Axis(f) for i in 1:3]

f.layout[1, 1] = subgl_left
f.layout[1, 2] = subgl_right

f

# %% 6

f = Figure(size = (800, 800))

Axis(f[1, 1], title = "No grid layout")
Axis(f[2, 1], title = "No grid layout")
Axis(f[3, 1], title = "No grid layout")

Axis(f[1, 2], title = "Inside", alignmode = Inside())
Axis(f[2, 2], title = "Outside", alignmode = Outside())
Axis(f[3, 2], title = "Outside(50)", alignmode = Outside(50))

[Box(f[i, 2], color = :transparent, strokecolor = :red) for i in 1:3]

f

# %% 7

f = Figure()

Axis(f[1, 1:2], title = "[1, 1:2]")
Axis(f[2:4, 1:2], title = "[2:4, 1:2]")
Axis(f[:, 3], title = "[:, 3]")
Axis(f[1:3, 4], title = "[1:3, 4]")
Axis(f[end, end], title = "[end, end]")

f

# %% 8

f = Figure(size = (800, 800))

Axis(f[1, 1])
for i in 1:3
    Axis(f[:, end+1])
    Axis(f[end+1, :])
end

Label(f[0, :], text = "Super Title", fontsize = 50)
Label(f[end+1, :], text = "Sub Title", fontsize = 50)
Label(f[1:end-1, 0], text = "Left Text", fontsize = 50,
    rotation = pi/2)
Label(f[1:end-1, end+1], text = "Right Text", fontsize = 50,
    rotation = -pi/2)

f

# %% 9

f = Figure(size = (800, 800))

for i in 1:3, j in 1:3
    Axis(f[i, j])
end

Label(f[0, :], text = "First Supertitle", fontsize = 20)
Label(f[-1, :], text = "Second Supertitle", fontsize = 30)
Label(f[-2, :], text = "Third Supertitle", fontsize = 40)

f

# %% 10

f = Figure()

ax1 = Axis(f[1, 1], title = "Axis 1")
ax2 = Axis(f[1, 2], title = "Axis 2")

f

# %% 11
f[2, 1] = ax2

f

# %% 12
trim!(f.layout)

f

# %% 13

fig = Figure()

axs = [Axis(fig[i, j]) for i in 1:3, j in 1:3]
axs[1, 1].title = "Group A"
axs[1, 2].title = "Group B.1"
axs[1, 3].title = "Group B.2"

hidedecorations!.(axs, grid=false)

colgap!(fig.layout, 1, Relative(0.15))

fig

# %% 14
rowgap!(fig.layout, 50)

fig
