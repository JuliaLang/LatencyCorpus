# env: makie
# kind: unknown
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/how-to/save-figure-with-transparency.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
f = Figure(backgroundcolor = (:blue, 0.4))
Axis(f[1, 1], backgroundcolor = (:tomato, 0.5))
f

# %% 2
# pruned: failed without tiering
