# env: plots
# kind: unknown
# source: backends.md

# %% prelude
using Plots

# %% 1
# pruned: failed without tiering
# %% 2
# pruned: failed without tiering
# %% 3
using Plots; gr()

x = range(-3, 3, length=30)
surface(
  x, x, (x, y)->exp(-x^2 - y^2), c=:viridis, legend=:none,
  nx=50, ny=50, display_option=Plots.GR.OPTION_SHADED_MESH,  # <-- series[:extra_kwargs]
)

# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
# %% 8
# pruned: failed without tiering
# %% 9
# pruned: failed without tiering
# %% 10
plot(1:5, add = raw"\draw (1,2) rectangle (2,3);", extra_kwargs = :subplot)

# %% 11
# pruned: failed without tiering
# %% 12
# pruned: failed without tiering
# %% 13
# pruned: failed without tiering
# %% 14
# pruned: failed without tiering
