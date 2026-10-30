# env: base
# kind: throughput
# about: Plain-Julia numerical kernels written as a user would: n-body, a Mandelbrot image,
#   a sieve, a sparse solve and a dictionary-heavy graph search.

# %% nbody
using LinearAlgebra, SparseArrays, Random
mutable struct Body
    pos::Vector{Float64}
    vel::Vector{Float64}
    mass::Float64
end
function step!(bodies, dt)
    for (i, a) in enumerate(bodies), j in i+1:length(bodies)
        b = bodies[j]
        d = b.pos - a.pos
        f = dt / norm(d)^3
        a.vel .+= d .* (f * b.mass)
        b.vel .-= d .* (f * a.mass)
    end
    for b in bodies
        b.pos .+= dt .* b.vel
    end
end
rng = Xoshiro(9)
bodies = [Body(randn(rng, 3), zeros(3), rand(rng)) for _ in 1:40]
for _ in 1:30_000
    step!(bodies, 1e-4)
end
sum(b.mass * norm(b.vel)^2 for b in bodies) / 2

# %% mandelbrot
function escape(c, maxiter)
    z = zero(c)
    for k in 1:maxiter
        z = z * z + c
        abs2(z) > 4 && return k
    end
    return maxiter
end
img = [escape(complex(x, y), 500) for y in range(-1.2, 1.2; length=3000), x in range(-2, 0.6; length=4000)]
sum(img)

# %% sieve
function primes_upto(n)
    is = trues(n)
    is[1] = false
    for i in 2:isqrt(n)
        is[i] || continue
        for j in i*i:i:n
            is[j] = false
        end
    end
    return findall(is)
end
length(primes_upto(200_000_000))

# %% sparse solve
n = 700
L = spdiagm(-1 => -ones(n - 1), 0 => 2ones(n), 1 => -ones(n - 1))
A = kron(L, sparse(I, n, n)) + kron(sparse(I, n, n), L)
b = rand(rng, n^2)
x = A \ b
norm(A * x - b)

# %% graph search
function word_ladder(words, from, to)
    dict = Set(words)
    prev = Dict(from => from)
    frontier = [from]
    while !isempty(frontier)
        next = String[]
        for w in frontier, i in eachindex(w), c in 'a':'z'
            v = string(w[1:i-1], c, w[i+1:end])
            (v in dict && !haskey(prev, v)) || continue
            prev[v] = w
            v == to && return prev
            push!(next, v)
        end
        frontier = next
    end
    return prev
end
words = unique([String(rand(rng, 'a':'f', 5)) for _ in 1:30_000])
length(word_ladder(words, words[1], words[end]))
