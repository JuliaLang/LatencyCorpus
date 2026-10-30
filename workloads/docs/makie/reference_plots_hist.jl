# env: makie
# kind: unknown
# source: reference/plots/hist.md

# %% prelude
using CairoMakie

# %% 1
data = randn(1000)

hist(data, normalization = :pdf, bar_labels = :values,
     label_formatter=x-> round(x, digits=2), label_size = 15,
     strokewidth = 0.5, strokecolor = (:black, 0.5), color = :values)

# %% 2
fig = Figure()
ax = Axis(fig[1, 1])
for i in 1:5
     hist!(ax, randn(1000), scale_to=-0.6, offset=i, direction=:x)
end
fig

# %% 3
using Distributions


N = 100_000
x = rand(Uniform(-5, 5), N)

w = pdf.(Normal(), x)

fig = Figure()
hist(fig[1,1], x)
hist(fig[1,2], x, weights = w)

fig

# %% 4
data1 = rand(100) .* 2.0 .- 1.0
data2 = rand(100) .* 2.0
data3 = randn(200)

f = Figure(size = (800, 400))
hist(
     f[1, 1], vcat(data1, data2, data3),
     stack = vcat(fill(3, 100), fill(2, 100), fill(1, 200)),
     colormap = :Set3_10, color = :stack,
     strokecolor = :black, strokewidth = 1,
)
hist(
     f[1, 2], [data1, data2, data3], dodge = [1, 2, 3],
     color = [:tomato, :aqua, :darkgreen],
)

f
