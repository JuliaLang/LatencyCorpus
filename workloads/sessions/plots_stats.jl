# env: plots
# kind: interactive
# about: Statistical plots from a data frame: box plots and densities by group, a fitted distribution.

# %% load
using StatsPlots, DataFrames, Distributions, Random

# %% data
rng = Xoshiro(8)
df = DataFrame(group = rand(rng, ["a", "b", "c"], 600), value = randn(rng, 600))
df.value .+= map(g -> g == "a" ? 0.0 : g == "b" ? 1.0 : 2.5, df.group)

# %% box plot
@df df boxplot(:group, :value; label = "")

# %% densities
@df df density(:value; group = :group)

# %% fit
d = fit(Normal, df.value)

# %% histogram with the fit
histogram(df.value; normalize = :pdf, label = "data")
plot!(x -> pdf(d, x), -3, 6; label = "fitted normal", linewidth = 2)
