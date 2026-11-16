# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/ecdf.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()
Axis(f[1, 1])

ecdfplot!(randn(200))

f

# %% 2
f = Figure()
Axis(f[1, 1])

x = randn(200)
ecdfplot!(x, color = (:blue, 0.3))
ecdfplot!(x, color = :red, npoints=10)

f

# %% 3
f = Figure()
Axis(f[1, 1])

x = rand(200)
w = @. x^2 * (1 - x)^2
ecdfplot!(x)
ecdfplot!(x; weights = w, color=:orange)

f
