# env: makie
# kind: interactive
# about: Quick figures with CairoMakie, as in a first exploration: lines, labelled scatter, histogram, two panels, save.

# %% load
using CairoMakie, Random

# %% data
rng = Xoshiro(6)
x = 1:200
y = cumsum(randn(rng, 200))

# %% lines
lines(x, y; axis = (xlabel = "step", ylabel = "value"))

# %% scatter with labels
fig, ax, sc = scatter(randn(rng, 50), randn(rng, 50); color = 1:50, markersize = 12)
ax.title = "Random points"
Colorbar(fig[1, 2], sc)
fig

# %% histogram
hist(randn(rng, 2_000); bins = 40)

# %% two panels
f = Figure(size = (800, 400))
lines(f[1, 1], x, y)
barplot(f[1, 2], 1:10, rand(rng, 10))
f

# %% save
save("panels.png", f)
filesize("panels.png") > 0
