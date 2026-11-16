# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/reference/plots/image.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
using FileIO

img = load(assetpath("cow.png"))

f = Figure()

image(f[1, 1], img,
    axis = (title = "Default",))

image(f[1, 2], img,
    axis = (aspect = DataAspect(), title = "DataAspect()",))

image(f[2, 1], rotr90(img),
    axis = (aspect = DataAspect(), title = "rotr90",))

image(f[2, 2], img',
    axis = (aspect = DataAspect(), yreversed = true,
        title = "img' and reverse y-axis",))

f
