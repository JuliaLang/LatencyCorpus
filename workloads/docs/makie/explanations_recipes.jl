# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/recipes.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie
CairoMakie.activate!() # hide

struct StockValue{T<:Real}
    open::T
    close::T
    high::T
    low::T
end

# %% 2
@recipe StockChart begin
    downcolor = :red
    upcolor = :green
end
nothing # hide

# %% 3
function Makie.plot!(
        sc::StockChart{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:StockValue}}})

    # We use the two converted arguments as input nodes for our computation.
    # These match the types in the tuple above, i.e.
    # AbstractVector{<: Real}, AbstractVector{<: StockValue}
    input_nodes = [:converted_1, :converted_2]

    # As outputs we want to compute data for `linesegments` and `barplot`
    output_nodes = [:linesegments, :bar_tos, :color, :barpos]

    # This will register a computation in the graph, which connects a new set of
    # output_nodes to the given input_nodes in a way that can dynamically update.
    map!(sc.attributes, input_nodes, output_nodes) do times, stockvalues
        # Note that the order of inputs and outputs must match the order of
        # input_nodes and output_nodes respectively

        linesegments = Point2f[]
        for (t, s) in zip(times, stockvalues)
            push!(linesegments, Point2f(t, s.low))
            push!(linesegments, Point2f(t, s.high))
        end

        barpos = [Point2f(t, s.open) for (t, s) in zip(times, stockvalues)]
        bar_tos = [s.close for s in stockvalues]
        colors = [x.close > x.open for x in stockvalues]

        return (linesegments, bar_tos, colors, barpos)
    end

    # For colors we use a vector of booleans, which are interpreted as numbers
    # and thus get colored based on the colormap. To get the correct colors we
    # build a colormap containing just `downcolor` and `upcolor` here
    map!((dc, uc) -> [dc, uc], sc.attributes, [:downcolor, :upcolor], :colormap)

    # Now we define how the StockChart is visualized through other plot types.
    # For this we pass the nodes we added to the StockChart plot:
    linesegments!(sc, sc.linesegments, color = sc.color, colormap = sc.colormap)

    # We can also pass the graph directly, which will cause the child plot
    # (barplot) to connect the correctly named attributes (color and colormap)
    # on its own
    barplot!(sc, sc.attributes, sc.barpos, fillto = sc.bar_tos, strokewidth = 0)

    return sc
end
nothing # hide

# %% 4
timestamps = 1:100

# we create some fake stock values in a way that looks pleasing later
startvalue = StockValue(0.0, 0.0, 0.0, 0.0)
stockvalues = foldl(timestamps[2:end], init = [startvalue]) do values, t
    open = last(values).close + 0.3 * randn()
    close = open + randn()
    high = max(open, close) + rand()
    low = min(open, close) - rand()
    push!(values, StockValue(
        open, close, high, low
    ))
end

# now we can use our new recipe
f = Figure()

stockchart(f[1, 1], timestamps, stockvalues)

# and let's try one where we change our default attributes
stockchart(f[2, 1], timestamps, stockvalues,
    downcolor = :purple, upcolor = :orange)
f

# %% 5
# pruned: failed without tiering
