# env: plots
# kind: interactive
# source: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/docs/src/ecosystem.md
# license: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/Plots/LICENSE.md

# %% prelude
using Plots

# %% 1
using StatsPlots, Plots, RDatasets, Distributions; gr()
Plots.reset_defaults()

iris = dataset("datasets", "iris")
singers = dataset("lattice","singer")
dist = Gamma(2)
a = [randn(100); randn(100) .+ 3; randn(100) ./ 2 .+ 3]
