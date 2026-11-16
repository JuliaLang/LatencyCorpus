# env: data
# kind: interactive
# source: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/docs/src/man/basics.md
# license: https://github.com/JuliaData/DataFrames.jl/blob/v1.8.2/LICENSE.md

# %% 1
using DataFrames

# %% 2
DataFrame()

# %% 3
DataFrame(A=1:3, B=5:7, fixed=1)

# %% 4
DataFrame("customer age" => [15, 20, 25],
          "first name" => ["Rohit", "Rahul", "Akshat"])

# %% 5
dict = Dict("customer age" => [15, 20, 25],
            "first name" => ["Rohit", "Rahul", "Akshat"])

# %% 6
DataFrame(dict)

# %% 7
dict = Dict(:customer_age => [15, 20, 25],
            :first_name => ["Rohit", "Rahul", "Akshat"])

# %% 8
DataFrame(dict)

# %% 9
DataFrame((a=[1, 2], b=[3, 4]))

# %% 10
DataFrame([(a=1, b=0), (a=2, b=0)])

# %% 11
DataFrame([1 0; 2 0], :auto)

# %% 12
mat = [1 2 4 5; 15 58 69 41; 23 21 26 69]

# %% 13
nms = ["a", "b", "c", "d"]

# %% 14
DataFrame(mat, nms)

# %% 15
using CSV

# %% 16
path = joinpath(pkgdir(DataFrames), "docs", "src", "assets", "german.csv");

# %% 17
german_ref = CSV.read(path, DataFrame)

# %% 18
german = copy(german_ref); # we copy the data frame

# %% 19
german.Sex

# %% 20
colname = "Sex"

# %% 21
german[!, colname]

# %% 22
german.Sex === german[!, :Sex]

# %% 23
german.Sex === german[:, :Sex]

# %% 24
names(german)

# %% 25
names(german, AbstractString)

# %% 26
propertynames(german)

# %% 27
eltype.(eachcol(german))

# %% 28
empty(german)

# %% 29
german

# %% 30
empty!(german)

# %% 31
german

# %% 32
german = copy(german_ref);

# %% 33
size(german)

# %% 34
size(german, 1)

# %% 35
size(german, 2)

# %% 36
nrow(german)

# %% 37
ncol(german)

# %% 38
describe(german)

# %% 39
describe(german, cols=1:3)

# %% 40
show(german, allcols=true)

# %% 41
using Statistics

# %% 42
mean(german.Age)

# %% 43
mapcols(id -> id .^ 2, german)

# %% 44
first(german, 6)

# %% 45
last(german, 5)

# %% 46
first(german)

# %% 47
last(german)

# %% 48
german[1:5, [:Sex, :Age]]

# %% 49
german[1:5, :]

# %% 50
german[[1, 6, 15], :]

# %% 51
german[:, [:Age, :Sex]]

# %% 52
german[!, [:Sex]]

# %% 53
german[!, :Sex]

# %% 54
german[4, 4]

# %% 55
view(german, :, 2:5)

# %% 56
@view german[end:-1:1, [1, 4]]

# %% 57
@view german[1:5, 1]

# %% 58
@view german[2, 2]

# %% 59
@view german[3, 2:5]

# %% 60
df1 = german[1:6, 2:4]

# %% 61
val = [80, 85, 98, 95, 78, 89]

# %% 62
df1.Age = val

# %% 63
df1

# %% 64
df1.Age === val # no copy is performed

# %% 65
df1[1:3, :Job] = [2, 3, 2]

# %% 66
df1

# %% 67
df1[!, :Sex] = ["male", "female", "female", "transgender", "female", "male"]

# %% 68
df1

# %% 69
df1[3, 1:3] = [78, "male", 4]

# %% 70
df1

# %% 71
dfr = df1[2, :] # DataFrameRow with the second row and all columns of df1

# %% 72
dfr.Age = 98 # set value of col `:Age` in row `2` to `98` in-place

# %% 73
dfr

# %% 74
dfr[2:3] = ["male", 2] # set values of entries in columns `:Sex` and `:Job`

# %% 75
dfr

# %% 76
sdf = view(df1, :, 2:3)

# %% 77
sdf[2, :Sex] = "female" # set value of col `:Sex` in second row to `female` in-place

# %% 78
sdf

# %% 79
sdf[6, 1:2] = ["female", 3]

# %% 80
sdf

# %% 81
s = [25, 26, 35, 56]

# %% 82
# pruned: failed without tiering
# %% 83
s[2:3] .= 0

# %% 84
s

# %% 85
df1[!, :Age] .= [85, 89, 78, 58, 96, 68] # col `:Age` is replaced freshly allocated vector

# %% 86
df1

# %% 87
df1[!, :Customers] .= ["Rohit", "Akshat", "Rahul", "Aayush", "Prateek", "Anam"]

# %% 88
df1[:, :City] .= ["Kanpur", "Lucknow", "Bhuvneshwar", "Jaipur", "Ranchi", "Dehradoon"]

# %% 89
df1

# %% 90
df1[:, 3] .= 4 # an in-place replacement of values stored in column number 3 by 4

# %% 91
df1

# %% 92
# pruned: failed without tiering
# %% 93
df1[!, :Age] .= "Economics"

# %% 94
df1

# %% 95
insertcols!(df1, 1, :Country => "India")

# %% 96
german[:, Not(:Age)]

# %% 97
german[:, Cols("Age", Between("Sex", "Job"))]

# %% 98
german[Not(5), r"S"]
