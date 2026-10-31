# env: data
# kind: interactive
# source: man/sorting.md

# %% 1
using DataFrames, CSV

# %% 2
path = joinpath(pkgdir(DataFrames), "docs", "src", "assets", "iris.csv");

# %% 3
iris = CSV.read(path, DataFrame)

# %% 4
sort!(iris)

# %% 5
sort!(iris, rev = true)

# %% 6
sort!(iris, [:Species, :SepalWidth])

# %% 7
sort!(iris, [order(:Species, by=length), order(:SepalLength, rev=true)])

# %% 8
sort!(iris, [:Species, :PetalLength], rev=[true, false])

# %% 9
sort!(iris, [order(:Species, rev=true), :PetalLength])
