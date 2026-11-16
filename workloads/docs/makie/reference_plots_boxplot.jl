# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/boxplot.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
categories = rand(1:3, 1000)
values = randn(1000)

boxplot(categories, values)

# %% 2
categories = rand(1:3, 1000)
values = randn(1000)
dodge = rand(1:2, 1000)

boxplot(categories, values, dodge = dodge, show_notch = true, color = dodge)

# %% 3
categories = rand(1:3, 1000)
values = randn(1000)
dodge = rand(1:2, 1000)

boxplot(categories, values, dodge = dodge, show_notch = true, color = map(d->d==1 ? :blue : :red, dodge) , outliercolor = rand([:red, :green, :blue, :black, :yellow], 1000))

# %% 4
using Distributions

N = 100_000
x = rand(1:3, N)
y = rand(Uniform(-1, 5), N)

w = pdf.(Normal(), x .- y)

fig = Figure()

boxplot(fig[1,1], x, y)
boxplot(fig[1,2], x, y, weights = w)

fig

# %% 5
fig = Figure()

categories = rand(1:3, 1000)
values = randn(1000)

ax_vert = Axis(fig[1,1];
    xlabel = "categories",
    ylabel = "values",
    xticks = (1:3, ["one", "two", "three"])
)
ax_horiz = Axis(fig[1,2];
    xlabel="values", # note that x/y still correspond to horizontal/vertical axes respectively
    ylabel="categories",
    yticks=(1:3, ["one", "two", "three"])
)

# Note: same order of category/value, despite different axes
boxplot!(ax_vert, categories, values) # `orientation=:vertical` is default
boxplot!(ax_horiz, categories, values; orientation=:horizontal)

fig
