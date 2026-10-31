# env: base
# kind: interactive
# about: Work with a list of records using only Base: define a struct, sort, filter, group, summarize.

# %% load
using Random, Statistics, Printf

# %% define
struct Employee
    name::String
    dept::Symbol
    salary::Float64
    years::Int
end
Base.show(io::IO, e::Employee) = print(io, "Employee(", e.name, ", ", e.dept, ")")

# %% make data
rng = Xoshiro(3)
depts = [:eng, :sales, :ops, :finance]
staff = [Employee(string("emp", i), rand(rng, depts), round(40_000 + 80_000rand(rng)), rand(rng, 0:25))
         for i in 1:5_000]

# %% sort and filter
senior = filter(e -> e.years >= 15, staff)
top = first(sort(senior; by = e -> e.salary, rev = true), 10)

# %% group
bydept = Dict{Symbol,Vector{Employee}}()
for e in staff
    push!(get!(bydept, e.dept, Employee[]), e)
end
Dict(d => length(v) for (d, v) in bydept)

# %% summarize
for d in sort(collect(keys(bydept)))
    v = bydept[d]
    @printf("%-8s n=%4d  mean %9.0f  median %9.0f  max years %2d\n", d, length(v),
        mean(e -> e.salary, v), median([e.salary for e in v]), maximum(e -> e.years, v))
end
