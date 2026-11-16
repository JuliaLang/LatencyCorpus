# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/crossbar.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
xs = [1, 1, 2, 2, 3, 3]
ys = rand(6)
ymins = ys .- 1
ymaxs = ys .+ 1
dodge = [1, 2, 1, 2, 1, 2]

crossbar(xs, ys, ymins, ymaxs, dodge = dodge, show_notch = true)
