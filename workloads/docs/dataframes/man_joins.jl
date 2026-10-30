# env: data
# kind: unknown
# source: man/joins.md

# %% 1
using DataFrames

# %% 2
people = DataFrame(ID=[20, 40], Name=["John Doe", "Jane Doe"])

# %% 3
jobs = DataFrame(ID=[20, 40], Job=["Lawyer", "Doctor"])

# %% 4
innerjoin(people, jobs, on = :ID)

# %% 5
jobs = DataFrame(ID=[20, 60], Job=["Lawyer", "Astronaut"])

# %% 6
innerjoin(people, jobs, on = :ID)

# %% 7
leftjoin(people, jobs, on = :ID)

# %% 8
rightjoin(people, jobs, on = :ID)

# %% 9
outerjoin(people, jobs, on = :ID)

# %% 10
semijoin(people, jobs, on = :ID)

# %% 11
antijoin(people, jobs, on = :ID)

# %% 12
crossjoin(people, jobs, makeunique = true)

# %% 13
# pruned: failed without tiering
# %% 14
a = DataFrame(ID=[20, 40], Name=["John Doe", "Jane Doe"])

# %% 15
b = DataFrame(IDNew=[20, 40], Job=["Lawyer", "Doctor"])

# %% 16
innerjoin(a, b, on = :ID => :IDNew)

# %% 17
a = DataFrame(City=["Amsterdam", "London", "London", "New York", "New York"],
              Job=["Lawyer", "Lawyer", "Lawyer", "Doctor", "Doctor"],
              Category=[1, 2, 3, 4, 5])

# %% 18
b = DataFrame(Location=["Amsterdam", "London", "London", "New York", "New York"],
              Work=["Lawyer", "Lawyer", "Lawyer", "Doctor", "Doctor"],
              Name=["a", "b", "c", "d", "e"])

# %% 19
innerjoin(a, b, on = [:City => :Location, :Job => :Work])

# %% 20
# pruned: failed without tiering
# %% 21
a = DataFrame(ID=[20, 40], Name=["John", "Jane"])

# %% 22
b = DataFrame(ID=[20, 60], Job=["Lawyer", "Doctor"])

# %% 23
outerjoin(a, b, on=:ID, validate=(true, true), source=:source)

# %% 24
innerjoin(a, b, on=:ID, renamecols = "_left" => "_right")

# %% 25
innerjoin(a, b, on=:ID, renamecols = lowercase => uppercase)

# %% 26
df1 = DataFrame(id=[1, missing, 3], a=1:3)

# %% 27
df2 = DataFrame(id=[1, 2, missing], b=1:3)

# %% 28
# pruned: failed without tiering
# %% 29
innerjoin(df1, df2, on=:id, matchmissing=:equal)

# %% 30
innerjoin(df1, df2, on=:id, matchmissing=:notequal)

# %% 31
df_left = DataFrame(id=[1, 2, 4, 5], left=1:4)

# %% 32
df_right = DataFrame(id=[2, 1, 3, 6, 7], right=1:5)

# %% 33
outerjoin(df_left, df_right, on=:id)

# %% 34
outerjoin(df_left, df_right, on=:id, order=:left)

# %% 35
outerjoin(df_left, df_right, on=:id, order=:right)

# %% 36
# pruned: failed without tiering
# %% 37
# pruned: failed without tiering
# %% 38
main
