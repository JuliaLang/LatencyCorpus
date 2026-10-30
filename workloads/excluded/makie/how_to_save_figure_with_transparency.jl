# env: makie
# kind: unknown
# source: how-to/save-figure-with-transparency.md

# %% prelude
using CairoMakie

# %% 1
f = Figure(backgroundcolor = (:blue, 0.4))
Axis(f[1, 1], backgroundcolor = (:tomato, 0.5))
f

# %% 2
# pruned: failed without tiering
