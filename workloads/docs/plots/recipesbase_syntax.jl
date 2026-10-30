# env: plots
# kind: unknown
# source: RecipesBase/syntax.md

# %% prelude
using Plots

# %% 1
using Plots, Random
Random.seed!(100)
default(legend = :topleft, markerstrokecolor = :auto, markersize = 6)

# %% 2
struct Result
    x::Vector{Float64}
    y::Vector{Float64}
    ε::Vector{Float64}
end

# %% 3
res = Result(1:10, cumsum(rand(10)), cumsum(rand(10)) / 5)

using Plots

# plot the error band as invisible line with fillrange
plot(
    res.x,
    res.y .+ res.ε,
    xlabel = "x",
    ylabel = "y",
    fill = (res.y .- res.ε, :lightgray, 0.5),
    linecolor = nothing,
    primary = false, # no legend entry
)

# add the data to the plots
plot!(res.x, res.y, marker = :diamond)

# %% 4
@recipe function f(r::Result; ε_max = 0.5)
    # set a default value for an attribute with `-->`
    xlabel --> "x"
    yguide --> "y"
    markershape --> :diamond
    # add a series for an error band
    @series begin
        # force an argument with `:=`
        seriestype := :path
        # ignore series in legend and color cycling
        primary := false
        linecolor := nothing
        fillcolor := :lightgray
        fillalpha := 0.5
        fillrange := r.y .- r.ε
        # ensure no markers are shown for the error band
        markershape := :none
        # return series data
        r.x, r.y .+ r.ε
    end
    # get the seriescolor passed by the user
    c = get(plotattributes, :seriescolor, :auto)
    # highlight big errors, otherwise use the user-defined color
    markercolor := ifelse.(r.ε .> ε_max, :red, c)
    # return data
    r.x, r.y
end

# %% 5
plot(res)

# %% 6
scatter(res, ε_max = 0.7, color = :green, marker = :star)
