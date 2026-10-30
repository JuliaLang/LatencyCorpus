# env: data
# kind: unknown
# source: man/missing.md

# %% 1
missing

# %% 2
typeof(missing)

# %% 3
x = [1, 2, missing]

# %% 4
eltype(x)

# %% 5
Union{Missing, Int}

# %% 6
eltype(x) == Union{Missing, Int}

# %% 7
skipmissing(x)

# %% 8
sum(skipmissing(x))

# %% 9
collect(skipmissing(x))

# %% 10
coalesce.(x, 0)

# %% 11
using DataFrames

# %% 12
df = DataFrame(i=1:5,
               x=[missing, 4, missing, 2, 1],
               y=[missing, missing, "c", "d", "e"])

# %% 13
dropmissing(df)

# %% 14
dropmissing(df, :x)

# %% 15
dropmissing(df, disallowmissing=true)

# %% 16
df = DataFrame(x=1:3, y=4:6)

# %% 17
allowmissing!(df)

# %% 18
df[1, 1] = missing

# %% 19
df

# %% 20
disallowmissing(df, :y)

# %% 21
disallowmissing(df, error=false)

# %% 22
passmissing(uppercase)("a")

# %% 23
passmissing(uppercase)(missing)

# %% 24
using Missings

# %% 25
Missings.replace(x, 1)

# %% 26
collect(Missings.replace(x, 1))

# %% 27
collect(Missings.replace(x, 1)) == coalesce.(x, 1)

# %% 28
eltype(x)

# %% 29
nonmissingtype(eltype(x))

# %% 30
missings(1)

# %% 31
missings(3)

# %% 32
missings(1, 3)

# %% 33
missings(Int, 1, 3)
