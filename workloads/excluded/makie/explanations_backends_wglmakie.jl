# env: makie
# kind: unknown
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/backends/wglmakie.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
N = 60
function xy_data(x, y)
    r = sqrt(x^2 + y^2)
    r == 0.0 ? 1f0 : (sin(r)/r)
end
l = range(-10, stop = 10, length = N)
z = Float32[xy_data(x, y) for x in l, y in l]
surface(
    -1..1, -1..1, z,
    colormap = :Spectral
)

# %% 2
# pruned: failed without tiering
# %% 3
# pruned: failed without tiering
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
