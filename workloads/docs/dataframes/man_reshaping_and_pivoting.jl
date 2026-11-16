# env: data
# kind: interactive
# source: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/docs/src/man/reshaping_and_pivoting.md
# license: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/LICENSE.md

# %% 1
using DataFrames, CSV

# %% 2
path = joinpath(pkgdir(DataFrames), "docs", "src", "assets", "iris.csv");

# %% 3
iris = CSV.read(path, DataFrame)

# %% 4
stack(iris, 1:4)

# %% 5
stack(iris, [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth])

# %% 6
stack(iris, [:SepalLength, :SepalWidth], :Species)

# %% 7
stack(iris, Not(:Species))

# %% 8
iris.id = 1:size(iris, 1)

# %% 9
longdf = stack(iris, Not([:Species, :id]))

# %% 10
unstack(longdf, :id, :variable, :value)

# %% 11
unstack(longdf, :variable, :value)

# %% 12
unstack(longdf)

# %% 13
stack(iris, view=true)

# %% 14
using Statistics

# %% 15
d = stack(iris, Not(:Species))

# %% 16
agg = combine(groupby(d, [:variable, :Species]), :value => mean => :vmean)

# %% 17
unstack(agg, :variable, :Species, :vmean)

# %% 18
unstack(d, :variable, :Species, :value, combine=mean)

# %% 19
df1 = DataFrame(a=["x", "y"], b=[1.0, 2.0], c=[3, 4], d=[true, false])

# %% 20
permutedims(df1, 1)

# %% 21
df2 = DataFrame(a=["x", "y"], b=[1, "two"], c=[3, 4], d=[true, false])

# %% 22
permutedims(df2, 1, "different_name")
