# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/blocks/legend.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1

f = Figure()

Axis(f[1, 1])

xs = 0:0.5:10
ys = sin.(xs)
lin = lines!(xs, ys, color = :blue)
sca = scatter!(xs, ys, color = :red)
sca2 = scatter!(xs, ys .+ 0.5, color = 1:length(xs), marker = :rect)

Legend(f[1, 2],
    [lin, sca, [lin, sca], sca2],
    ["a line", "some dots", "both together", "rect markers"])

f

# %% 2

f = Figure()

ax = f[1, 1] = Axis(f)

lines!(0..15, sin, label = "sin", color = :blue)
lines!(0..15, cos, label = "cos", color = :red)
lines!(0..15, x -> -cos(x), label = "-cos", color = :green)

f[1, 2] = Legend(f, ax, "Trig Functions", framevisible = false)

f

# %% 3

f = Figure()

traces = cumsum(randn(10, 5), dims = 1)

for (i, (merge, unique)) in enumerate(
        Iterators.product([false, true], [false true]))

    axis = Axis(f[fldmod1(i, 2)...],
        title = "merge = $merge, unique = $unique")

    for trace in eachcol(traces)
        lines!(trace, label = "single", color = (:black, 0.2))
    end

    mu = vec(sum(traces, dims = 2) ./ 5)
    lines!(mu, label = "mean")
    scatter!(mu, label = "mean")

    axislegend(axis, merge = merge, unique = unique)

end

f

# %% 4

f = Figure()

ax1 = Axis(f[1, 1])
ax2 = Axis(f[1, 2])

xs = range(0, 4pi, length = 31)
lines!(ax1, xs, sin, label = "sin", color = :blue)
lines!(ax2, xs, cos, label = "cos", color = :red)
scatter!(ax1, xs, sin, label = "Points", color = :black)
scatter!(ax2, xs, cos, label = "Points", color = :black)

f[0, 1:2] = Legend(f, [ax1, ax2], "Automatic Joint Legend", merge = true, orientation = :horizontal, tellheight = true)

f

# %% 5

f = Figure()

ax = Axis(f[1, 1])

sc1 = scatter!(randn(10, 2), color = :red, label = "Red Dots")
sc2 = scatter!(randn(10, 2), color = :blue, label = "Blue Dots")
scatter!(randn(10, 2), color = :orange, label = "Orange Dots")
scatter!(randn(10, 2), color = :cyan, label = "Cyan Dots")

axislegend()

axislegend("Titled Legend", position = :lb)

axislegend(ax, [sc1, sc2], ["One", "Two"], "Selected Dots", position = :rb,
    orientation = :horizontal)

f

# %% 6

haligns = [:left, :right, :center]
valigns = [:top, :bottom, :center]

f = Figure()

Axis(f[1, 1])

xs = 0:0.1:10
lins = [lines!(xs, sin.(xs .* i), color = color)
    for (i, color) in zip(1:3, [:red, :blue, :green])]

for (j, ha, va) in zip(1:3, haligns, valigns)
    Legend(
        f[1, 1], lins, ["Line $i" for i in 1:3],
        "$ha & $va",
        tellheight = false,
        tellwidth = false,
        margin = (10, 10, 10, 10),
        halign = ha, valign = va, orientation = :horizontal
    )
end

f

# %% 7

f = Figure()

Axis(f[1, 1])

elem_1 = [LineElement(color = :red, linestyle = nothing),
          MarkerElement(color = :blue, marker = 'x', markersize = 15,
          strokecolor = :black)]

elem_2 = [PolyElement(color = :red, strokecolor = :blue, strokewidth = 1),
          LineElement(color = :black, linestyle = :dash)]

elem_3 = LineElement(color = :green, linestyle = nothing,
        points = Point2f[(0, 0), (0, 1), (1, 0), (1, 1)])

elem_4 = MarkerElement(color = :blue, marker = 'π', markersize = 15,
        points = Point2f[(0.2, 0.2), (0.5, 0.8), (0.8, 0.2)])

elem_5 = PolyElement(color = :green, strokecolor = :black, strokewidth = 2,
        points = Point2f[(0, 0), (1, 0), (0, 1)])

Legend(f[1, 2],
    [elem_1, elem_2, elem_3, elem_4, elem_5],
    ["Line & Marker", "Poly & Line", "Line", "Marker", "Poly"],
    patchsize = (35, 35), rowgap = 10)

f

# %% 8
f, ax, sc = scatter(
    cos.(range(0, 7pi, 100)),
    color = :black,
    markersize = 8,
    label = "cos" => (; markersize = 15)
)
scatter!(
    sin.(range(0, 7pi, 100)),
    color = :black,
    marker = :utriangle,
    markersize = 8,
    label = "sin" => (; markersize = 15)
)
Legend(f[1, 2], ax)
f

# %% 9
f, ax, bp = barplot(
    1:5,
    [1, 3, 2, 5, 4],
    color = 1:5,
    colorrange = (1, 5),
    colormap = :Set1_5,
    label = [label => (; color = i)
        for (i, label) in enumerate(["red", "blue", "green", "purple", "orange"])]
)
Legend(f[1, 2], ax)
f

# %% 10
f = Figure()
ax = Axis(f[1, 1])
li = lines!(ax, 1:5, linestyle = :dot)
sc = scatter!(ax, 1:5, markersize = 10)
Legend(
    f[1, 2],
    [
        sc => (; markersize = 20),
        li => (; linewidth = 3),
        [li, sc] => (; color = :red),
        [li => (; linewidth = 3), sc => (; markersize = 20)],
    ],
    ["Scatter", "Line", "Both", "Both 2"],
    patchsize = (40, 20),
)
f

# %% 11

f = Figure()

markersizes = [5, 10, 15, 20]
colors = [:red, :green, :blue, :orange]

group_size = [MarkerElement(marker = :circle, color = :black,
    strokecolor = :transparent,
    markersize = ms) for ms in markersizes]

group_color = [PolyElement(color = color, strokecolor = :transparent)
    for color in colors]

legends = [Legend(f,
    [group_size, group_color],
    [string.(markersizes), string.(colors)],
    ["Size", "Color"], tellheight = true) for _ in 1:4]

f[1, 1:2] = legends[1:2]
f[2, :] = legends[3]
f[3, :] = legends[4]

for l in legends[3:4]
    l.orientation = :horizontal
    l.tellheight = true
    l.tellwidth = false
end

legends[2].titleposition = :left
legends[4].titleposition = :left

legends[1].nbanks = 2
legends[4].nbanks = 2

Label(f[1, 1, Left()], "titleposition = :top\norientation = :vertical\nnbanks = 2", font = :italic, padding = (0, 10, 0, 0))
Label(f[1, 2, Right()], "titleposition = :left\norientation = :vertical\nnbanks = 1", font = :italic, padding = (10, 0, 0, 0))
Label(f[2, 1:2, Top()], "titleposition = :top, orientation = :horizontal\nnbanks = 1", font = :italic)
Label(f[3, 1:2, Top()], "titleposition = :left, orientation = :horizontal\nnbanks = 2", font = :italic)

f

# %% 12
# pruned: failed without tiering
# %% 13
# pruned: failed without tiering
