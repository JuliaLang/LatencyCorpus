# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/qqnorm.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
xs = 2 .* randn(100) .+ 3

qqnorm(xs, qqline = :fitrobust)
