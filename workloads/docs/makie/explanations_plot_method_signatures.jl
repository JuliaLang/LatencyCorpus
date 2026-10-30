# env: makie
# kind: unknown
# source: explanations/plot_method_signatures.md

# %% prelude
using CairoMakie

# %% 1
# FigureAxisPlot takes figure and axis keywords
fig, ax, p = lines(cumsum(randn(1000)),
    figure = (size = (1000, 600),),
    axis = (ylabel = "Temperature",),
    color = :red)

# AxisPlot takes axis keyword
lines(fig[2, 1], cumsum(randn(1000)),
    axis = (xlabel = "Time (sec)", ylabel = "Stock Value"),
    color = :blue)

fig

# %% 2
fig = Figure()

# first row, first column
scatter(fig[1, 1], 1.0..10, sin)

# first row, second column
lines(fig[1, 2], 1.0..10, sin)

# first row, third column, then nested first row, first column
lines(fig[1, 3][1, 1], cumsum(randn(1000)), color = :blue)

# first row, third column, then nested second row, first column
lines(fig[1, 3][2, 1], cumsum(randn(1000)), color = :red)

# second row, first to third column
ax, hm = heatmap(fig[2, 1:3], randn(30, 10))

# across all rows, new column after the last one
fig[:, end+1] = Colorbar(fig, hm)

fig

# %% 3
fig = Figure()

lines(fig[1, 1], 1.0..10, sin, color = :blue)
# this works because the previous command created an axis at fig[1, 1]
lines!(fig[1, 1], 1.0..10, cos, color = :red)

# the following line wouldn't work yet because no axis exists at fig[1, 2]
# lines!(fig[1, 2], 1.0..10, sin, color = :green)

fig[1, 2] = Axis(fig)
# now it works
lines!(fig[1, 2], 1.0..10, sin, color = :green)

# also works with nested grids
fig[2, 1:2][1, 3] = Axis(fig)
lines!(fig[2, 1:2][1, 3], 1.0..10, cos, color = :orange)

# but often it's more convenient to save an axis to reuse it
ax, _ = lines(fig[2, 1:2][1, 1:2], 1.0..10, sin, color = :black)
lines!(ax, 1.0..10, cos, color = :yellow)

fig
