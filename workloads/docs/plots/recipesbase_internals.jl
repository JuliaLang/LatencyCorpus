# env: plots
# kind: interactive
# source: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/docs/src/RecipesBase/internals.md
# license: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/Plots/LICENSE.md

# %% prelude
using Plots

# %% 1
using Plots # hide
plot(histogram(randn(1000))) #hide
