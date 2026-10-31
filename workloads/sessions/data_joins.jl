# env: data
# kind: interactive
# about: Joins and display: combine two tables several ways, add derived columns, print the results.

# %% load
using DataFrames, PrettyTables, Random

# %% tables
rng = Xoshiro(4)
customers = DataFrame(cust = 1:500, name = ["c$i" for i in 1:500],
    region = rand(rng, ["east", "west", "north"], 500))
orders = DataFrame(order = 1:5_000, cust = rand(rng, 1:600, 5_000),
    amount = round.(200rand(rng, 5_000); digits = 2))

# %% inner join
j = innerjoin(orders, customers; on = :cust)

# %% left join with missing
lj = leftjoin(orders, customers; on = :cust)
count(ismissing, lj.region)

# %% derived columns
transform!(j, :amount => (a -> a .* 1.08) => :with_tax)
first(j, 8)

# %% totals by region
tot = combine(groupby(j, :region), :amount => sum => :total, nrow => :orders)
pretty_table(tot)

# %% antijoin
nrow(antijoin(customers, orders; on = :cust))
