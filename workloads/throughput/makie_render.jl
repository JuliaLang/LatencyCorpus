# env: makie
# kind: throughput
# about: Render large figures and an animation with CairoMakie.

# %% load
using CairoMakie, Random

# %% big scatter
rng = Xoshiro(7)
pts = randn(rng, 3_000_000, 2)
f = Figure(size=(1200, 900))
scatter(f[1, 1], pts[:, 1], pts[:, 2]; markersize=1, color=(:black, 0.1))
save("scatter.png", f)

# %% heatmap
z = [sin(x / 40) * cos(y / 55) + 0.1 * randn(rng) for x in 1:2000, y in 1:2000]
fig, ax, hm = heatmap(z; colormap=:viridis)
Colorbar(fig[1, 2], hm)
save("heatmap.png", fig)

# %% surface panels
fig = Figure(size=(1600, 1200))
for i in 1:3, j in 1:3
    ax = Axis3(fig[i, j]; title="mode $i,$j")
    xs = range(0, π; length=120)
    surface!(ax, xs, xs, [sin(i * x) * sin(j * y) for x in xs, y in xs])
end
save("modes.png", fig)

# %% animation
θ = Observable(0.0)
xs = range(0, 4π; length=400)
fig, ax, l = lines(xs, @lift(sin.(xs .+ $θ)); linewidth=3)
record(fig, "wave.mp4", range(0, 2π; length=360)) do v
    θ[] = v
end
