# env: base
# kind: latency
# about: Higher-order functions with fresh closures at each input, as typed at a REPL.

# %% data
using Random
xs = rand(Xoshiro(12), 1_000_000);

# %% map
map(x -> 2x + 1, xs) |> sum

# %% filter
filter(x -> x > 0.5, xs) |> length

# %% reduce
mapreduce(x -> x^2, +, xs)

# %% sort by
sort(xs; by=x -> abs(x - 0.5))[1:3]

# %% broadcast with closure
c = 3.0
f = x -> c * sin(x)
sum(f.(xs))

# %% comprehension with condition
[x^2 for x in xs if x < 0.01] |> length

# %% do block
count(xs) do x
    0.25 < x < 0.75
end

# %% composition
(sqrt ∘ abs ∘ (x -> x - 0.5)).(xs) |> maximum
