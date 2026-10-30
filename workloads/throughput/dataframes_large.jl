# env: data
# kind: throughput
# about: Split-apply-combine, sorting and joins on tables with millions of rows.

# %% load
using DataFrames, Statistics, Random

# %% build
rng = Xoshiro(6)
n = 15_000_000
df = DataFrame(id=rand(rng, 1:100_000, n), group=rand(rng, ["a", "b", "c", "d", "e"], n),
    x=randn(rng, n), y=rand(rng, n));

# %% combine
g = combine(groupby(df, [:group, :id]), :x => mean => :mx, :y => maximum => :my, nrow => :n)
nrow(g)

# %% transform
transform!(groupby(df, :group), :x => (x -> (x .- mean(x)) ./ std(x)) => :z)
extrema(df.z)

# %% sort
sort!(df, [:group, order(:x; rev=true)])
first(df, 3)

# %% join
lookup = DataFrame(id=1:100_000, weight=rand(rng, 100_000))
j = innerjoin(df, lookup; on=:id)
sum(j.x .* j.weight)

# %% filter and reshape
w = unstack(combine(groupby(subset(df, :y => ByRow(>(0.5))), [:id, :group]), :x => sum => :sx),
    :id, :group, :sx)
size(w)
