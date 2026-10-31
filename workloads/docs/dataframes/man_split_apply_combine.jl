# env: data
# kind: interactive
# source: man/split_apply_combine.md

# %% 1
using DataFrames, CSV, Statistics

# %% 2
path = joinpath(pkgdir(DataFrames), "docs", "src", "assets", "iris.csv");

# %% 3
iris = CSV.read(path, DataFrame)

# %% 4
iris_gdf = groupby(iris, :Species)

# %% 5
combine(iris_gdf, :PetalLength => mean)

# %% 6
combine(iris_gdf, nrow, proprow, groupindices)

# %% 7
combine(iris_gdf, nrow, :PetalLength => mean => :mean)

# %% 8
combine(iris_gdf,
        [:PetalLength, :SepalLength] =>
        ((p, s) -> (a=mean(p)/mean(s), b=sum(p))) =>
        AsTable) # multiple columns are passed as arguments

# %% 9
combine(iris_gdf,
        AsTable([:PetalLength, :SepalLength]) =>
        x -> std(x.PetalLength) / std(x.SepalLength)) # passing a NamedTuple

# %% 10
combine(x -> std(x.PetalLength) / std(x.SepalLength), iris_gdf) # passing a SubDataFrame

# %% 11
combine(iris_gdf, 1:2 => cor, nrow)

# %% 12
combine(iris_gdf, :PetalLength => (x -> [extrema(x)]) => [:min, :max])

# %% 13
combine(iris_gdf) do df
    (m = mean(df.PetalLength), s² = var(df.PetalLength))
end

# %% 14
combine(iris_gdf, valuecols(iris_gdf) .=> mean)

# %% 15
df = DataFrame(id=1:2)

# %% 16
gd = groupby(df, :id)

# %% 17
push!(df, [3])

# %% 18
# pruned: failed without tiering
# %% 19
df = DataFrame(id=1:2)

# %% 20
gd = groupby(view(df, :, :), :id)

# %% 21
push!(df, [3])

# %% 22
gd[1]

# %% 23
for subdf in iris_gdf
    println(size(subdf, 1))
end

# %% 24
for (key, subdf) in pairs(iris_gdf)
    println("Number of data points for $(key.Species): $(nrow(subdf))")
end

# %% 25
iris_gdf[(Species="Iris-virginica",)]  # a NamedTuple

# %% 26
iris_gdf[[("Iris-virginica",), ("Iris-setosa",)]] # a vector of Tuples

# %% 27
key = keys(iris_gdf) |> last # last key in iris_gdf

# %% 28
iris_gdf[key]

# %% 29
iris_gdf[Dict("Species" => "Iris-setosa")] # a dictionary

# %% 30
sdf_vec = collect(iris_gdf)

# %% 31
map(nrow, sdf_vec)

# %% 32
nrow.(sdf_vec)

# %% 33
[nrow(sdf) for sdf in iris_gdf]

# %% 34
df = DataFrame(a=1:5)

# %% 35
sdf = @view df[2:3, :]

# %% 36
transform(sdf, :a => ByRow(string)) # create a new data frame

# %% 37
transform!(sdf, :a => ByRow(string)) # update the source df in-place

# %% 38
df # new column was created filled with missing in filtered-out rows

# %% 39
select!(sdf, :a => -, renamecols=false) # update the source df in-place

# %% 40
df # the column replaced an existing column; previously stored values are re-used in filtered-out rows

# %% 41
df = DataFrame(a=[1, 1, 1, 2, 2, 3], b=1:6)

# %% 42
sdf = @view df[2:4, :]

# %% 43
gsdf = groupby(sdf, :a)

# %% 44
transform(gsdf, nrow) # create a new data frame

# %% 45
transform!(gsdf, nrow, :b => :b_copy)

# %% 46
df

# %% 47
select!(gsdf, :b_copy, :b => sum, renamecols=false)

# %% 48
df

# %% 49
df = DataFrame(customer_id=["a", "b", "b", "b", "c", "c"],
               transaction_id=[12, 15, 19, 17, 13, 11],
               volume=[2, 3, 1, 4, 5, 9])

# %% 50
gdf = groupby(df, :customer_id, sort=true);

# %% 51
show(gdf, allgroups=true)

# %% 52
combine(gdf, nrow)

# %% 53
combine(gdf, nrow => "transaction_count")

# %% 54
combine(df, nrow => "transaction_count")

# %% 55
nrow(df)

# %% 56
combine(gdf, proprow)

# %% 57
combine(gdf, proprow => "transaction_fraction")

# %% 58
combine(gdf, groupindices)

# %% 59
transform(gdf, groupindices)

# %% 60
combine(gdf, groupindices => "group_number")

# %% 61
groupindices(gdf)

# %% 62
combine(gdf, eachindex)

# %% 63
select(gdf, eachindex, groupindices)

# %% 64
combine(gdf, eachindex => "transaction_number")

# %% 65
transform(df, eachindex)

# %% 66
collect(eachindex(df.customer_id))

# %% 67
combine(gdf, eachindex, :customer_id => eachindex)

# %% 68
combine(gdf, eachindex, sdf -> axes(sdf, 1))

# %% 69
# pruned: failed without tiering
# %% 70
combine(gdf, nrow, sdf -> nrow(sdf))

# %% 71
push!(df, ["a", 100, 100]) # push row with large integer values to disable default sorting

# %% 72
keys(groupby(df, :volume))
