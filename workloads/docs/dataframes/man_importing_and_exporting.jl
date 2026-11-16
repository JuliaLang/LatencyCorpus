# env: data
# kind: interactive
# source: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/docs/src/man/importing_and_exporting.md
# license: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/LICENSE.md

# %% 1
using DelimitedFiles, DataFrames

# %% 2
path = joinpath(pkgdir(DataFrames), "docs", "src", "assets", "iris.csv");

# %% 3
data, header = readdlm(path, ',', header=true);

# %% 4
iris_raw = DataFrame(data, vec(header))

# %% 5
iris = identity.(iris_raw)
