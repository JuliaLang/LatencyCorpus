# env: data
# kind: unknown
# source: lib/metadata.md

# %% 1
using DataFrames

# %% 2
df = DataFrame(name=["Jan Krzysztof Duda", "Jan Krzysztof Duda",
                     "Radosław Wojtaszek", "Radosław Wojtaszek"],
               date=["2022-Jun", "2021-Jun", "2022-Jun", "2021-Jun"],
               rating=[2750, 2729, 2708, 2687])

# %% 3
metadatakeys(df)

# %% 4
metadata!(df, "caption", "ELO ratings of chess players", style=:note);

# %% 5
collect(metadatakeys(df))

# %% 6
"caption" in metadatakeys(df)

# %% 7
metadata(df, "caption")

# %% 8
metadata(df, "caption", style=true)

# %% 9
emptymetadata!(df);

# %% 10
metadatakeys(df)

# %% 11
colmetadatakeys(df)

# %% 12
colmetadata!(df, :name, "label", "First and last name of a player", style=:note);

# %% 13
colmetadata!(df, :date, "label", "Rating date in yyyy-u format", style=:note);

# %% 14
colmetadata!(df, :rating, "label", "ELO rating in classical time control", style=:note);

# %% 15
"label" in colmetadatakeys(df, :rating)

# %% 16
colmetadata(df, :rating, "label")

# %% 17
colmetadata(df, :rating, "label", style=true)

# %% 18
collect(colmetadatakeys(df))

# %% 19
[only(names(df, col)) =>
 [key => colmetadata(df, col, key) for key in metakeys] for
 (col, metakeys) in colmetadatakeys(df)]

# %% 20
emptycolmetadata!(df);

# %% 21
colmetadatakeys(df)
