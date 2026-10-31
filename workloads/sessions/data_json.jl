# env: data
# kind: interactive
# about: JSON at the REPL: parse a document, pull out fields, turn records into a table, write JSON back.

# %% load
using JSON3, DataFrames, Random

# %% make a document
rng = Xoshiro(9)
items = [Dict("id" => i, "name" => "item$i", "price" => round(100rand(rng); digits = 2),
              "tags" => rand(rng, ["new", "sale", "hot", "eco"], rand(rng, 1:3)),
              "stock" => Dict("warehouse" => rand(rng, 0:500), "store" => rand(rng, 0:50)))
         for i in 1:2_000]
text = JSON3.write(Dict("generated" => "2026-10-31", "items" => items))
sizeof(text)

# %% parse
doc = JSON3.read(text)
doc.items[1]

# %% fields
total_stock = sum(it -> it.stock.warehouse + it.stock.store, doc.items)

# %% to a table
df = DataFrame((id = it.id, name = it.name, price = it.price, ntags = length(it.tags),
                instock = it.stock.store > 0) for it in doc.items)
first(df, 5)

# %% filter and write
cheap = filter(r -> r.price < 10 && r.instock, df)
JSON3.write(copy.(eachrow(cheap)))[1:200]
