# env: data
# kind: interactive
# about: Read a medium-sized CSV, describe it, group and summarize, sort, and print a table.

# %% load
using CSV, DataFrames, Statistics, Random, PrettyTables

# %% make a file
rng = Xoshiro(21)
n = 100_000
cities = ["Boston", "Denver", "Austin", "Seattle", "Miami", "Chicago"]
df0 = DataFrame(id = 1:n, city = rand(rng, cities, n), age = rand(rng, 18:90, n),
    income = round.(30_000 .+ 90_000 .* rand(rng, n)), score = randn(rng, n))
CSV.write("people.csv", df0)

# %% read
df = CSV.read("people.csv", DataFrame)

# %% describe
describe(df)

# %% group
g = combine(groupby(df, :city), nrow => :n, :income => mean => :income, :age => median => :age,
    :score => std => :score_sd)

# %% sort and print
sort!(g, :income; rev = true)
pretty_table(g)

# %% age bands
df.band = map(a -> a < 30 ? "18-29" : a < 50 ? "30-49" : a < 70 ? "50-69" : "70+", df.age)
unstack(combine(groupby(df, [:city, :band]), nrow => :n), :city, :band, :n)
