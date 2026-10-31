# env: makie
# kind: interactive
# source: explanations/specapi.md

# %% prelude
using CairoMakie

# %% 1
import Makie.SpecApi as S
Makie.inline!(true) # hide
CairoMakie.activate!() # hide

plot(
    S.GridLayout([
        (1, 1) => S.Axis(),
        (1, 2) => S.Axis(),
        (2, :) => S.Axis(),
        (2, 2, Right()) => S.Box(),
        (2, 2, Right()) => S.Label(
            text = "Label",
            rotation = pi/2,
            padding = (10, 10, 10, 10)
        ),
    ])
)

# %% 2
import Makie.SpecApi as S
Makie.inline!(true) # hide
CairoMakie.activate!() # hide

plot(S.GridLayout([
    (1, 1) => S.Axis(),
    (1, 2) => S.Axis(),
    (2, :) => S.GridLayout(fill(S.Axis(), 1, 3)),
]))

# %% 3
import Makie.SpecApi as S
axis_matrix = broadcast(1:2, (1:2)') do x, y
    S.Axis(; title="$x, $y")
end
layout = S.GridLayout(
    axis_matrix;
    xaxislinks=vec(axis_matrix[1:2, 1]),
    yaxislinks=vec(axis_matrix[1:2, 2])
)
f, _, pl = plot(layout)
# Change limits to see the links in action
for ax in f.content[[1, 3]]
    limits!(ax, 2, 3, 2, 3)
end
f

# %% 4
import Makie.SpecApi as S

# Our custom type we want to write a conversion method for
struct PlotGrid
    nplots::Tuple{Int,Int}
end

# If we want to use the `color` attribute in the conversion, we have to
# mark it via `used_attributes`
Makie.used_attributes(::PlotGrid) = (:color,)

# The conversion method creates a grid of `Axis` objects with `Lines` plot inside
# We restrict to Plot{plot}, so that only `plot(PlotGrid(...))` works, but not e.g. `scatter(PlotGrid(...))`.
function Makie.convert_arguments(::Type{Plot{plot}}, obj::PlotGrid; color=:black)
    axes = [
        S.Axis(plots=[S.Lines(cumsum(randn(1000)); color=color)])
            for i in 1:obj.nplots[1],
                j in 1:obj.nplots[2]
    ]
    return S.GridLayout(axes)
end

# Now, when we plot `PlotGrid` we get a whole facet layout
plot(PlotGrid((3, 4)))

# %% 5
f = Figure()
plot(f[1, 1], PlotGrid((2, 2)); color=Cycled(1))
plot(f[1, 2], PlotGrid((3, 2)); color=Cycled(2))
f

# %% 6
import Makie.SpecApi as S
using Random

Random.seed!(123)

# define a struct for `convert_arguments`
struct CustomMatrix
    data::Matrix{Float32}
    style::Symbol
    kw::Dict{Symbol,Any}
end
CustomMatrix(data; style, kw...) = CustomMatrix(data, style, Dict{Symbol,Any}(kw))

function Makie.convert_arguments(::Type{<:AbstractPlot}, obj::CustomMatrix)
    plots = PlotSpec[]
    if obj.style === :heatmap
        push!(plots, S.Heatmap(obj.data; obj.kw...))
    elseif obj.style === :contourf
        push!(plots, S.Contourf(obj.data; obj.kw...))
    end
    max_position = Tuple(argmax(obj.data))
    push!(plots, S.Scatter(max_position; markersize = 30, strokecolor = :white, color = :transparent, strokewidth = 4))
    return plots
end

data = randn(30, 30)

f = Figure()
ax = Axis(f[1, 1])
# We can either plot into an existing Axis
plot!(ax, CustomMatrix(data, style = :heatmap, colormap = :Blues))
# Or create a new one automatically as we are used to from the standard API
plot(f[1, 2], CustomMatrix(data, style = :contourf, colormap = :inferno))
f

# %% 7
# pruned: failed without tiering
