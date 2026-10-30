# env: base
# kind: latency
# about: One generic function called on many argument types, each only a few times.

# %% types
norm2(t) = sum(x -> x^2, t)
values = Any[]
for n in 1:12
    push!(values, ntuple(i -> i, n))
    push!(values, ntuple(i -> Float64(i), n))
    push!(values, ntuple(i -> isodd(i) ? i : Float32(i), n))
end
length(values)

# %% calls
[norm2(v) for _ in 1:5 for v in values]
