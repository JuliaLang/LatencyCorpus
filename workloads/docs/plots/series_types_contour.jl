# env: plots
# kind: interactive
# source: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/docs/src/series_types/contour.md
# license: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/Plots/LICENSE.md

# %% prelude
using Plots

# %% 1
using Plots
Plots.reset_defaults()

# %% 2
# pruned: failed without tiering
# %% 3
using LaTeXStrings

f(x, y) = (3x + y^2) * abs(sin(x) + cos(y))

x = range(0, 5, length=100)
y = range(0, 3, length=50)
z = @. f(x', y)

contour(x, y, z, levels=10, color=:turbo, clabels=true, cbar=false, lw=1)
title!(L"Plot of $(3x + y^2)|\sin(x) + \cos(y)|$")
xlabel!(L"x")
ylabel!(L"y")

# %% 4
contourf(x, y, z, levels=20, color=:turbo)
title!(L"(3x + y^2)|\sin(x) + \cos(y)|")
xlabel!(L"x")
ylabel!(L"y")

# %% 5
g(x, y) = log(x*y)

x = 10 .^ range(0, 6, length=100)
y = 10 .^ range(0, 6, length=100)
z = @. g(x', y)
contourf(x, y, z, color=:plasma, scale=:log10,
    title=L"\log(xy)", xlabel=L"x", ylabel=L"y")

# %% 6
h(x, y) = exp(x^2 + y^2)

x = range(-3, 3, length=100)
y = range(-3, 3, length=100)
z = @. h(x', y)

tv = 0:8
tl = [L"10^{%$i}" for i in tv]
contourf(x, y, log10.(z), color=:turbo, levels=8,
    colorbar_ticks=(tv, tl), aspect_ratio=:equal,
    title=L"\exp(x^{2} + y^{2})", xlabel=L"x", ylabel=L"y")
