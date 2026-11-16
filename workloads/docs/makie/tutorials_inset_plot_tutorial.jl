# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/tutorials/inset-plot-tutorial.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie
using Random

# %% 2
Random.seed!(123)
time = 1:500
stock_price = cumsum(randn(500) .+ 0.5)

# %% 3
fig = Figure(size = (800, 600))

ax_main = Axis(fig[1, 1],
    title="Stock Price Over Time",
    xlabel="Days",
    ylabel="Price")

line_main = lines!(ax_main, time, stock_price, color=:blue)
fig

# %% 4
ax_inset = Axis(fig[1, 1],
    width=Relative(0.2),
    height=Relative(0.2),
    halign=0.1,
    valign=0.9,
    title="Zoomed View")

# %% 5
xlims!(ax_inset, 50, 70)
min_price, max_price = extrema(stock_price[50:70])
ylims!(ax_inset, min_price, max_price)
line_inset = lines!(ax_inset, time, stock_price, color=:red)
fig

# %% 6
translate!(ax_inset.blockscene, 0, 0, 150)

# %% 7
Legend(fig[1, 2], [line_main, line_inset], ["Stock Price", "Zoomed Region"])

# %% 8
border_rect = Rect2(50, min_price, 20, max_price - min_price)
lines!(ax_main, border_rect, color=:black, linewidth=1)
save("output.png", fig) # hide
fig
