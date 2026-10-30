# env: plots
# kind: throughput
# about: Plots with many series and points, and a GIF animation.

# %% load
using Plots, Random

# %% many series
rng = Xoshiro(8)
p = plot(cumsum(randn(rng, 5000, 40); dims=1); legend=false, lw=0.5)
savefig(p, "walks.png")

# %% subplots
plots = [histogram(randn(rng, 100_000) .* i; bins=100, title="σ = $i") for i in 1:9]
savefig(plot(plots...; layout=(3, 3), size=(1200, 900)), "hists.png")

# %% animation
anim = @animate for t in range(0, 2π; length=300)
    x = range(0, 4π; length=500)
    plot(x, sin.(x .+ t); ylim=(-1.2, 1.2), legend=false)
    scatter!(x[1:25:end], cos.(x[1:25:end] .- t))
end
gif(anim, "wave.gif"; fps=20)
