# env: plots
# kind: unknown
# source: input_data.md

# %% prelude
using Plots

# %% 1
using Plots; gr()
Plots.reset_defaults()

# %% 2
using Plots

# 10 data points in 4 series
xs = range(0, 2π, length = 10)
data = [sin.(xs) cos.(xs) 2sin.(xs) 2cos.(xs)]

# We put labels in a row vector: applies to each series
labels = ["Apples" "Oranges" "Hats" "Shoes"]

# Marker shapes in a column vector: applies to data points
markershapes = [:circle, :star5]

# Marker colors in a matrix: applies to series and data points
markercolors = [
    :green :orange :black :purple
    :red   :yellow :brown :white
]

plot(
    xs,
    data,
    label = labels,
    shape = markershapes,
    color = markercolors,
    markersize = 10
)

# %% 3
x1, x2 = [1, 0],  [2, 3]    # vectors
y1, y2 = [4, 5],  [6, 7]    # vectors
m1, m2 = [x1 y1], [x2 y2]   # 2x2 matrices

plot([m1, m2])              # array of matrices -> 4 series, plots each matrix column, x assumed to be integer count
plot([[x1,y1], [x2,y2]])    # array of array of arrays -> 4 series, plots each individual array, x assumed to be integer count
plot([(x1,y1), (x2,y2)])    # array of tuples of arrays -> 2 series, plots each tuple as new series

# %% 4
# pruned: failed without tiering
# %% 5
using StatsPlots, RDatasets
gr()
iris = dataset("datasets", "iris")
@df iris scatter(
    :SepalLength,
    :SepalWidth,
    group = :Species,
    m = (0.5, [:+ :h :star7], 12),
    bg = RGB(0.2, 0.2, 0.2)
)

# %% 6
using Plots
tmin = 0
tmax = 4π
tvec = range(tmin, tmax, length = 100)

plot(sin.(tvec), cos.(tvec))

# %% 7
plot(sin, cos, tvec)

# %% 8
plot(sin, cos, tmin, tmax)

# %% 9
using Plots

function make_batman()
    p = [(0, 0), (0.5, 0.2), (1, 0), (1, 2),  (0.3, 1.2), (0.2, 2), (0, 1.7)]
    s = [(0.2, 1), (0.4, 1), (2, 0), (0.5, -0.6), (0, 0), (0, -0.15)]
    m = [(p[i] .+ p[i + 1]) ./ 2 .+ s[i] for i in 1:length(p) - 1]

    pts = similar(m, 0)
    for (i, mi) in enumerate(m)
        append!(
            pts,
            map(BezierCurve([p[i], m[i], p[i + 1]]), range(0, 1, length = 30))
        )
    end
    x, y = Plots.unzip(Tuple.(pts))
    Shape(vcat(x, -reverse(x)), vcat(y, reverse(y)))
end

# background and limits
plt = plot(
    bg = :black,
    xlim = (0.1, 0.9),
    ylim = (0.2, 1.5),
    framestyle = :none,
    size = (400, 400),
    legend = false,
)

# %% 10
# create an ellipse in the sky
pts = Plots.partialcircle(0, 2π, 100, 0.1)
x, y = Plots.unzip(pts)
x = 1.5x .+ 0.7
y .+= 1.3
pts = collect(zip(x, y))

# beam
beam = Shape([(0.3, 0.0), pts[95], pts[50], (0.3, 0.0)])
plot!(beam, fillcolor = plot_color(:yellow, 0.3))

# %% 11
# spotlight
plot!(Shape(x, y), c = :yellow)

# %% 12
# buildings
rect(w, h, x, y) = Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])
gray(pct) = RGB(pct, pct, pct)
function windowrange(dim, denom)
    range(0, 1, length = max(3, round(Int, dim/denom)))[2:end - 1]
end

for k in 1:50
    local w, h, x, y = 0.1rand() + 0.05, 0.8rand() + 0.3, rand(), 0.0
    shape = rect(w, h, x, y)
    graypct = 0.3rand() + 0.3
    plot!(shape, c = gray(graypct))

    # windows
    I = windowrange(w, 0.015)
    J = windowrange(h, 0.04)
    local pts = vec([(Float64(x + w * i), Float64(y + h * j)) for i in I, j in J])
    windowcolors = Symbol[rand() < 0.2 ? :yellow : :black for i in 1:length(pts)]
    scatter!(pts, marker = (stroke(0), :rect, windowcolors))
end
plt

# %% 13
# Holy plotting, Batman!
batman = Plots.scale(make_batman(), 0.07, 0.07, (0, 0))
batman = translate(batman, 0.7, 1.23)
plot!(batman, fillcolor = :black)
