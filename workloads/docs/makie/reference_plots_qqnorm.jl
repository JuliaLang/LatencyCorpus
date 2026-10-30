# env: makie
# kind: unknown
# source: reference/plots/qqnorm.md

# %% prelude
using CairoMakie

# %% 1
xs = 2 .* randn(100) .+ 3

qqnorm(xs, qqline = :fitrobust)
