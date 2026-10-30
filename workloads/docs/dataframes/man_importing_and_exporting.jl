# env: data
# kind: unknown
# source: man/importing_and_exporting.md

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
