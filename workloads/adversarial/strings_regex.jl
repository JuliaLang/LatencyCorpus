# env: base
# kind: mixed
# about: Log processing with regular expressions and string building.

# %% log
using Random, Dates
rng = Xoshiro(11)
levels = ("INFO", "WARN", "ERROR", "DEBUG")
lines = [string(DateTime(2026, 1, 1) + Second(i), " [", rand(rng, levels), "] user=", rand(rng, 1:500),
                " path=/api/v", rand(rng, 1:3), "/items/", rand(rng, 1:10_000), " ms=", rand(rng, 1:900))
         for i in 1:300_000];

# %% parse
re = r"^(\S+) \[(\w+)\] user=(\d+) path=(\S+) ms=(\d+)$"
parsed = [match(re, l) for l in lines]
count(!isnothing, parsed)

# %% aggregate
slow = Dict{String,Int}()
for m in parsed
    parse(Int, m[5]) > 800 && (slow[m[2]] = get(slow, m[2], 0) + 1)
end
slow

# %% rewrite
redacted = replace.(lines, r"user=\d+" => "user=***")
redacted[1]

# %% report
io = IOBuffer()
for (lvl, n) in sort!(collect(slow); by=last, rev=true)
    println(io, lpad(lvl, 6), " ", "#"^(n ÷ 500), " ", n)
end
print(String(take!(io)))
