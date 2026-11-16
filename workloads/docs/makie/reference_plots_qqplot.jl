# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/qqplot.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
xs = randn(100)
ys = randn(100)

qqplot(xs, ys, qqline = :identity)

# %% 2
using Distributions

xs = randn(100)

qqplot(Normal, xs, qqline = :identity)

# %% 3
using Distributions

xs = randn(100)

qqplot(xs, distribution = Normal(0, 1), qqline = :identity)
