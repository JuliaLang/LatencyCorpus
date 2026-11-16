# env: plots
# kind: interactive
# source: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/docs/src/colorschemes.md
# license: https://github.com/JuliaPlots/Plots.jl/blob/Plots-v1.41.7/Plots/LICENSE.md

# %% prelude
using Plots

# %% 1
using Plots; gr()
Plots.reset_defaults()

# %% 2
plot(
    [x -> sin(x - a) for a in range(0, π / 2, length = 5)], 0, 2π;
    palette = :Dark2_5,
)

# %% 3
function f(x, y)
    r = sqrt(x^2 + y^2)
    return cos(r) / (1 + r)
end
x = range(0, 2π, length = 30)
heatmap(x, x, f, c = :thermal)

# %% 4
palette(:tab10)

# %% 5
palette([:purple, :green], 7)

# %% 6
cgrad(:acton)

# %% 7
cgrad([:orange, :blue], [0.1, 0.3, 0.8])

# %% 8
cgrad(:thermal, rev = true)

# %% 9
cgrad(:matter, 5, categorical = true)

# %% 10
cgrad(:matter, [0.1, 0.3, 0.8], rev = true, categorical = true)

# %% 11
cgrad(:roma, scale = :log)

# %% 12
cgrad(:roma, 10, categorical = true, scale = :exp)
