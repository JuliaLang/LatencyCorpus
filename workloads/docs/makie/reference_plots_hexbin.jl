# env: makie
# kind: unknown
# source: reference/plots/hexbin.md

# %% prelude
using CairoMakie

# %% 1
using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = rand(300)
y = rand(300)

for i in 2:5
    ax = Axis(f[fldmod1(i-1, 2)...], title = "bins = $i", aspect = DataAspect())
    hexbin!(ax, x, y, bins = i)
    wireframe!(ax, Rect2f(Point2f.(x, y)), color = :red)
    scatter!(ax, x, y, color = :red, markersize = 5)
end

f

# %% 2
using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = rand(300)
y = rand(300)

for i in 2:5
    ax = Axis(f[fldmod1(i-1, 2)...], title = "bins = (3, $i)", aspect = DataAspect())
    hexbin!(ax, x, y, bins = (3, i))
    wireframe!(ax, Rect2f(Point2f.(x, y)), color = :red)
    scatter!(ax, x, y, color = :red, markersize = 5)
end

f

# %% 3
using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = rand(300)
y = rand(300)

for (i, cellsize) in enumerate([0.1, 0.15, 0.2, 0.25])
    ax = Axis(f[fldmod1(i, 2)...], title = "cellsize = ($cellsize, $cellsize)", aspect = DataAspect())
    hexbin!(ax, x, y, cellsize = (cellsize, cellsize))
    wireframe!(ax, Rect2f(Point2f.(x, y)), color = :red)
    scatter!(ax, x, y, color = :red, markersize = 5)
end

f

# %% 4
using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = rand(300)
y = rand(300)

for (i, cellsize) in enumerate([0.1, 0.15, 0.2, 0.25])
    ax = Axis(f[fldmod1(i, 2)...], title = "cellsize = $cellsize", aspect = DataAspect())
    hexbin!(ax, x, y, cellsize = cellsize)
    wireframe!(ax, Rect2f(Point2f.(x, y)), color = :red)
    scatter!(ax, x, y, color = :red, markersize = 5)
end

f

# %% 5
using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = randn(100000)
y = randn(100000)

for (i, threshold) in enumerate([1, 10, 100, 500])
    ax = Axis(f[fldmod1(i, 2)...], title = "threshold = $threshold", aspect = DataAspect())
    hexbin!(ax, x, y, cellsize = 0.4, threshold = threshold)
end
f

# %% 6
using Random
Random.seed!(1234)

x = randn(100000)
y = randn(100000)

f = Figure()
hexbin(f[1, 1], x, y, bins = 40,
    axis = (aspect = DataAspect(), title = "colorscale = identity"))
hexbin(f[1, 2], x, y, bins = 40, colorscale=log10,
    axis = (aspect = DataAspect(), title = "colorscale = log10"))
f

# %% 7
using DelimitedFiles


a = map(Point2f, eachrow(readdlm(assetpath("airportlocations.csv"))))

f, ax, hb = hexbin(a,
    cellsize = 6,
    axis = (; aspect = DataAspect()),
    threshold = 0,
    colormap = [Makie.to_color(:transparent); Makie.to_colormap(:viridis)],
    strokewidth = 0.5,
    strokecolor = :gray50,
    colorscale = Makie.pseudolog10)

tightlimits!(ax)

Colorbar(f[1, 2], hb,
    label = "Number of airports",
    height = Relative(0.5)
)
f

# %% 8
using CairoMakie.Makie # hide
using CairoMakie.Makie.StatsBase # hide

using Random
Random.seed!(1234)

f = Figure(size = (800, 800))

x = 1:100
y = 1:100
points = vec(Point2f.(x, y'))

weights = [nothing, rand(length(points)), Makie.StatsBase.eweights(length(points), 0.005), Makie.StatsBase.weights(randn(length(points)))]
weight_labels = ["No weights", "Vector{<: Real}", "Exponential weights (StatsBase.eweights)", "StatesBase.weights(randn(...))"]

for (i, (weight, title)) in enumerate(zip(weights, weight_labels))
    ax = Axis(f[fldmod1(i, 2)...], title = title, aspect = DataAspect())
    hexbin!(ax, points; weights = weight)
    autolimits!(ax)
end

f
