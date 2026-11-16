# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/barplot.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()
Axis(f[1, 1])

xs = 1:0.2:10
ys = 0.5 .* sin.(xs)

barplot!(xs, ys, color = :red, strokecolor = :black, strokewidth = 1)
barplot!(xs, ys .- 1, fillto = -1, color = xs, strokecolor = :black, strokewidth = 1)

f

# %% 2
xs = 1:0.2:10
ys = 0.5 .* sin.(xs)

barplot(xs, ys, gap = 0, color = :gray85, strokecolor = :black, strokewidth = 1)

# %% 3
tbl = (cat = [1, 1, 1, 2, 2, 2, 3, 3, 3],
       height = 0.1:0.1:0.9,
       grp = [1, 2, 3, 1, 2, 3, 1, 2, 3],
       grp1 = [1, 2, 2, 1, 1, 2, 1, 1, 2],
       grp2 = [1, 1, 2, 1, 2, 1, 1, 2, 1]
       )

barplot(tbl.cat, tbl.height, color = tbl.grp,
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                title = "Stacked bars"),
        )

# %% 4
barplot(tbl.cat, tbl.height,
        stack = tbl.grp,
        color = tbl.grp,
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                title = "Stacked bars"),
        )

# %% 5
barplot(tbl.cat, tbl.height,
        stack = tbl.grp,
        color = tbl.grp,
        fillto = 0.05,
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                yscale = log10,
                title = "Stacked bars on a log axis"),
        )

# %% 6
barplot(tbl.cat, tbl.height,
        dodge = tbl.grp,
        color = tbl.grp,
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                title = "Dodged bars"),
        )

# %% 7
barplot(tbl.cat, tbl.height,
        dodge = [1, 2, 4, 1, 2, 4, 1, 2, 4],
        color = [1, 2, 4, 1, 2, 4, 1, 2, 4],
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                title = "Dodged bars"),
        )

# %% 8
barplot(tbl.cat, tbl.height,
        dodge = tbl.grp1,
        stack = tbl.grp2,
        color = tbl.grp,
        axis = (xticks = (1:3, ["left", "middle", "right"]),
                title = "Dodged and stacked bars"),
        )

# %% 9
colors = Makie.wong_colors()

# Figure and Axis
fig = Figure()
ax = Axis(fig[1,1], xticks = (1:3, ["left", "middle", "right"]),
        title = "Dodged bars with legend")

# Plot
barplot!(ax, tbl.cat, tbl.height,
        dodge = tbl.grp,
        color = colors[tbl.grp])

# Legend
labels = ["group 1", "group 2", "group 3"]
elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]
title = "Groups"

Legend(fig[1,2], elements, labels, title)

fig

# %% 10
barplot(
    tbl.cat, tbl.height,
    dodge = tbl.grp,
    color = tbl.grp,
    bar_labels = :y,
    axis = (xticks = (1:3, ["left", "middle", "right"]),
            title = "Dodged bars horizontal with labels"),
    colormap = [:red, :green, :blue],
    color_over_background=:red,
    color_over_bar=:white,
    flip_labels_at=0.85,
    direction=:x,
)

# %% 11
barplot([-1, -0.5, 0.5, 1],
    bar_labels = :y,
    axis = (title="Fonts + flip_labels_at",),
    label_size = 20,
    flip_labels_at=(-0.8, 0.8),
    label_color=[:white, :green, :black, :white],
    label_formatter = x-> "Flip at $(x)?",
    label_offset = 10
)

# %% 12
gantt = (
    machine = [1, 2, 1, 2],
    job = [1, 1, 2, 3],
    task = [1, 2, 3, 3],
    start = [1, 3, 3.5, 5],
    stop = [3, 4, 5, 6]
)

fig = Figure()
ax = Axis(
    fig[2,1],
    yticks = (1:2, ["A","B"]),
    ylabel = "Machine",
    xlabel = "Time"
)
xlims!(ax, 0, maximum(gantt.stop))

cmap = Makie.to_colormap(:tab10)

barplot!(
    gantt.machine,
    gantt.stop,
    fillto = gantt.start,
    direction = :x,
    color = gantt.job,
    colormap = cmap,
    colorrange = (1, length(cmap)),
    gap = 0.5,
    bar_labels = ["task #$i" for i in gantt.task],
    label_position = :center,
    label_color = :white,
    label = ["job #$i" => (; color = i) for i in unique(gantt.job)]
)

Legend(fig[1,1], ax, "Jobs", orientation=:horizontal, tellwidth = false, tellheight = true)

fig
