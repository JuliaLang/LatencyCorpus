# env: plots
# kind: interactive
# source: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/docs/src/contributing.md
# license: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/Plots/LICENSE.md

# %% prelude
using Plots

# %% 1
using Plots; gr()
Plots.reset_defaults()

# %% 2
using Plots, StatsBase
gr(size = (300, 300), leg = false)

@userplot MyCount
@recipe function f(mc::MyCount)
    # get the array from the args field
    arr = mc.args[1]

    T = typeof(arr)
    if T.parameters[1] == Float64
        seriestype := :histogram
        arr
    else
        seriestype := :bar
        cm = countmap(arr)
        x = sort!(collect(keys(cm)))
        y = [cm[xi] for xi ∈ x]
        x, y
    end
end

# %% 3
mycount(rand(500))

# %% 4
mycount(rand(["A","B","C"],100))

# %% 5
mycount(rand(1:500, 500))
