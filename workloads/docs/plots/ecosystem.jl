# env: plots
# kind: interactive
# source: ecosystem.md

# %% prelude
using Plots

# %% 1
using StatsPlots, Plots, RDatasets, Distributions; gr()
Plots.reset_defaults()

iris = dataset("datasets", "iris")
singers = dataset("lattice","singer")
dist = Gamma(2)
a = [randn(100); randn(100) .+ 3; randn(100) ./ 2 .+ 3]
