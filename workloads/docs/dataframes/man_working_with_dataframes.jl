# env: data
# kind: interactive
# source: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/docs/src/man/working_with_dataframes.md
# license: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/LICENSE.md

# %% 1
using DataFrames

# %% 2
df = DataFrame(A=1:2:1000, B=repeat(1:10, inner=50), C=1:500)

# %% 3
first(df, 6)

# %% 4
last(df, 6)

# %% 5
using CategoricalArrays

# %% 6
DataFrame(a=1:2, b=[1.0, missing],
          c=categorical('a':'b'), d=[1//2, missing])

# %% 7
df[1:3, :]

# %% 8
df[[1, 5, 10], :]

# %% 9
df[:, [:A, :B]]

# %% 10
df[1:3, [:B, :A]]

# %% 11
df[[3, 1], [:C]]

# %% 12
df[!, [:A]]

# %% 13
df[!, [:A]] == df[:, [:A]]

# %% 14
df[!, :A]

# %% 15
df[!, :A] == df[:, :A]

# %% 16
df = DataFrame(x1=1, x2=2, y=3)

# %% 17
df[!, r"x"]

# %% 18
df[!, Not(:x1)]

# %% 19
df = DataFrame(r=1, x1=2, x2=3, y=4)

# %% 20
df[:, Not(:r)] # drop :r column

# %% 21
df[:, Between(:r, :x2)] # keep columns between :r and :x2

# %% 22
df[:, All()] # keep all columns

# %% 23
df[:, Cols(x -> startswith(x, "x"))] # keep columns whose name starts with "x"

# %% 24
df[:, Cols(r"x", :)]

# %% 25
df[:, Cols(Not(r"x"), :)]

# %% 26
df = DataFrame(A=1:2:1000, B=repeat(1:10, inner=50), C=1:500)

# %% 27
df[df.A .> 500, :]

# %% 28
df[(df.A .> 500) .& (300 .< df.C .< 400), :]

# %% 29
df[in.(df.A, Ref([1, 5, 601])), :]

# %% 30
subset(df, :A => a -> a .< 10, :C => c -> isodd.(c))

# %% 31
df = DataFrame(x=[1, 2, missing, 4])

# %% 32
subset(df, :x => x -> coalesce.(iseven.(x), false))

# %% 33
subset(df, :x => x -> iseven.(x), skipmissing=true)

# %% 34
df = DataFrame(x1=[1, 2], x2=[3, 4], y=[5, 6])

# %% 35
select(df, Not(:x1)) # drop column :x1 in a new data frame

# %% 36
select(df, r"x") # select columns containing 'x' character

# %% 37
select(df, :x1 => :a1, :x2 => :a2) # rename columns

# %% 38
select(df, :x1, :x2 => (x -> x .- minimum(x)) => :x2) # transform columns

# %% 39
select(df, :x2, :x2 => ByRow(sqrt)) # transform columns by row

# %% 40
select(df, :x1, :x2, [:x1, :x2] => ((x1, x2) -> x1 ./ x2) => :z) # transform multiple columns

# %% 41
select(df, :x1, :x2, [:x1, :x2] => ByRow((x1, x2) -> x1 / x2) => :z)  # transform multiple columns by row

# %% 42
select(df, AsTable(:) => ByRow(extrema) => [:lo, :hi]) # return multiple columns

# %% 43
select(df, :x1)

# %% 44
df[:, :x1]

# %% 45
select!(df, Not(:x1));

# %% 46
df

# %% 47
df = DataFrame(x1=[1, 2], x2=[3, 4], y=[5, 6])

# %% 48
transform(df, All() => +)

# %% 49
df = DataFrame(A=1:4, B=["M", "F", "F", "M"])

# %% 50
describe(df)

# %% 51
describe(df[!, [:A]])

# %% 52
using Statistics

# %% 53
mean(df.A)

# %% 54
df = DataFrame(A=1:4, B=4.0:-1.0:1.0)

# %% 55
combine(df, All() .=> sum)

# %% 56
combine(df, All() .=> sum, All() .=> prod)

# %% 57
combine(df, All() .=> [sum prod]) # the same using 2-dimensional broadcasting

# %% 58
df = DataFrame(A=1:4, B=4.0:-1.0:1.0)

# %% 59
df2 = copy(df);

# %% 60
df2.A === df.A

# %% 61
x = [3, 1, 2];

# %% 62
df = DataFrame(x=x)

# %% 63
sort!(df)

# %% 64
x

# %% 65
df.x[1] = 100

# %% 66
df

# %% 67
x

# %% 68
x = [3, 1, 2];

# %% 69
df = DataFrame(x=x)

# %% 70
df.x == x

# %% 71
df[!, 1] !== x

# %% 72
eachcol(df)[1] === df.x

# %% 73
using DataFrames

# %% 74
df = DataFrame(a=["a", "None", "b", "None"], b=1:4,
               c=["None", "j", "k", "h"], d=["x", "y", "None", "z"])

# %% 75
replace!(df.a, "None" => "c")

# %% 76
df

# %% 77
df[:, [:c, :d]] .= ifelse.(df[!, [:c, :d]] .== "None", "c", df[!, [:c, :d]])

# %% 78
df

# %% 79
df .= ifelse.(df .== "c", "None", df) # replacement on entire data frame

# %% 80
df2 = ifelse.(df .== "None", missing, df) # do not operate in-place (`df = ` would also work)

# %% 81
allowmissing!(df) # operate in-place after allowing for missing

# %% 82
df .= ifelse.(df .== "None", missing, df)
