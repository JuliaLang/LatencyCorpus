# env: base
# kind: latency
# about: Data-analysis script with only stdlibs: summary statistics, regression, a report.

# %% data
using Random, Statistics, LinearAlgebra, Printf
rng = Xoshiro(4)
n = 10_000
x = randn(rng, n, 3)
y = x * [1.5, -2.0, 0.5] .+ 0.3 .* randn(rng, n);

# %% summaries
[mean(x; dims=1); std(x; dims=1); median(x; dims=1)]

# %% regression
X = [ones(n) x]
beta = X \ y
resid = y - X * beta
r2 = 1 - sum(abs2, resid) / sum(abs2, y .- mean(y))

# %% correlations
cor([x y])

# %% report
for (name, b) in zip(("intercept", "x1", "x2", "x3"), beta)
    @printf("%-10s %8.4f\n", name, b)
end
@printf("R² = %.4f\n", r2)
