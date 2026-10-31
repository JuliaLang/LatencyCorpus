# env: plots
# kind: interactive
# source: series_types/histogram.md

# %% prelude
using Plots

# %% 1
using Plots; gr()
Plots.reset_defaults()

# %% 2
using Plots

x = randn(10^3)
histogram(x)

# %% 3
p(x) = 1/sqrt(2pi) * exp(-x^2/2)
b_range = range(-5, 5, length=21)

histogram(x, label="Experimental", bins=b_range, normalize=:pdf, color=:gray)
plot!(p, label="Analytical", lw=3, color=:red)
xlims!(-5, 5)
ylims!(0, 0.4)
title!("Normal distribution, 1000 samples")
xlabel!("x")
ylabel!("P(x)")

# %% 4
f_exp(x) = exp(x)/(exp(1)-1)

x = rand(10^4)
w = exp.(x)

histogram(x, label="Experimental", bins=:scott, weights=w, normalize=:pdf, color=:gray)
plot!(f_exp, label="Analytical", lw=3, color=:red)
plot!(legend=:topleft)
xlims!(0, 1.0)
ylims!(0, 1.6)
title!("Uniform distribution, weighted by exp(x)")
xlabel!("x")
ylabel!("P(x)")

# %% 5
p1 = histogram(x, title="Bar")
p2 = scatterhist(x, title="Scatter")
p3 = stephist(x, title="Step")
plot(p1, p2, p3, layout=(1, 3), legend=false)

# %% 6
x = randn(10^4)
y = randn(10^4)
histogram2d(x, y)

# %% 7
w = exp.(x)
histogram2d(x, y, bins=(40, 20), show_empty_bins=true,
    normalize=:pdf, weights=w, color=:plasma)
title!("Normalized 2D Histogram")
xlabel!("x")
ylabel!("y")
