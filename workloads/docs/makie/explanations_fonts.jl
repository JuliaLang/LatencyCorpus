# env: makie
# kind: unknown
# source: explanations/fonts.md

# %% prelude
using CairoMakie

# %% 1
using Makie
Makie.to_font("Blackchancery")

# %% 2
using Makie
Makie.theme(:fonts)

# %% 3
f = Figure(fontsize = 24, fonts = (; regular = "Dejavu", weird = "Blackchancery"))
Axis(f[1, 1], title = "A title", xlabel = "An x label", xlabelfont = :weird)

f
