# env: data
# kind: latency
# about: Typical CSV session: write a file, read it back, clean, summarize, join, write.

# %% load
using CSV, DataFrames, Statistics, Dates, Random

# %% make a file
rng = Xoshiro(5)
n = 50_000
open("sales.csv", "w") do io
    println(io, "date,store,product,units,price,note")
    for i in 1:n
        note = rand(rng) < 0.1 ? "\"promo, weekend\"" : ""
        units = rand(rng) < 0.02 ? "" : string(rand(rng, 1:20))
        println(io, Date(2025, 1, 1) + Day(rand(rng, 0:364)), ',', "S", rand(rng, 1:12), ',',
            rand(rng, ("apple", "pear", "plum", "fig")), ',', units, ',',
            round(rand(rng) * 5 + 0.5; digits=2), ',', note)
    end
end

# %% read
df = CSV.read("sales.csv", DataFrame)

# %% inspect
describe(df)

# %% clean
dropmissing!(df, :units)
df.revenue = df.units .* df.price
df.month = month.(df.date)
first(df, 5)

# %% summarize
by_store = combine(groupby(df, :store), :revenue => sum => :revenue, :units => mean => :avg_units)
sort!(by_store, :revenue; rev=true)

# %% pivot
monthly = unstack(combine(groupby(df, [:month, :product]), :revenue => sum => :revenue),
    :month, :product, :revenue)

# %% join
stores = DataFrame(store=["S$i" for i in 1:12], region=repeat(["north", "south", "east"], 4))
regional = combine(groupby(innerjoin(df, stores; on=:store), :region), :revenue => sum)

# %% write
CSV.write("monthly.csv", monthly)
CSV.read("monthly.csv", DataFrame; select=[:month, :apple])
