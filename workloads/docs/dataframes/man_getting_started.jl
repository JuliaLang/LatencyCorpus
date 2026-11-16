# env: data
# kind: interactive
# source: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/docs/src/man/getting_started.md
# license: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/LICENSE.md

# %% 1
using DataFrames

# %% 2
DataFrame(a=1:4, b=["M", "F", "F", "M"]) # keyword argument constructor

# %% 3
DataFrame((a=[1, 2], b=[3, 4])) # Tables.jl table constructor from a named tuple of vectors

# %% 4
DataFrame([(a=1, b=0), (a=2, b=0)]) # Tables.jl table constructor from a vector of named tuples

# %% 5
DataFrame("a" => 1:2, "b" => 0) # Pair constructor

# %% 6
DataFrame([:a => 1:2, :b => 0]) # vector of Pairs constructor

# %% 7
DataFrame(Dict(:a => 1:2, :b => 0)) # dictionary constructor

# %% 8
DataFrame([[1, 2], [0, 0]], [:a, :b]) # vector of vectors constructor

# %% 9
DataFrame([1 0; 2 0], :auto) # matrix constructor

# %% 10
df = DataFrame(A=1:4, B=["M", "F", "F", "M"])

# %% 11
df.A

# %% 12
df."A"

# %% 13
df.A === df[!, :A]

# %% 14
df.A === df[:, :A]

# %% 15
df.A == df[:, :A]

# %% 16
df.A === df[!, "A"]

# %% 17
df.A === df[:, "A"]

# %% 18
df.A == df[:, "A"]

# %% 19
df.A === df[!, 1]

# %% 20
df.A === df[:, 1]

# %% 21
df.A == df[:, 1]

# %% 22
firstcolumn = :A

# %% 23
df[!, firstcolumn] === df.A

# %% 24
df[:, firstcolumn] === df.A

# %% 25
df[:, firstcolumn] == df.A

# %% 26
names(df)

# %% 27
names(df, r"A") # a regular expression selector

# %% 28
names(df, Int) # a selector using column element type

# %% 29
names(df, Not(:B)) # selector keeping all columns except :B

# %% 30
propertynames(df)

# %% 31
df = DataFrame()

# %% 32
df.A = 1:8

# %% 33
df[:, :B] = ["M", "F", "F", "M", "F", "M", "M", "F"]

# %% 34
df[!, :C] .= 0

# %% 35
df

# %% 36
size(df, 1)

# %% 37
size(df, 2)

# %% 38
size(df)

# %% 39
# pruned: failed without tiering
# %% 40
# pruned: failed without tiering
# %% 41
df.B = df.B .== "F"

# %% 42
df

# %% 43
df = DataFrame(A=Int[], B=String[])

# %% 44
push!(df, (1, "M"))

# %% 45
push!(df, [2, "N"])

# %% 46
push!(df, Dict(:B => "F", :A => 3))

# %% 47
v = [(a=1, b=2), (a=3, b=4)]

# %% 48
df = DataFrame(v)

# %% 49
using Tables

# %% 50
Tables.rowtable(df)
