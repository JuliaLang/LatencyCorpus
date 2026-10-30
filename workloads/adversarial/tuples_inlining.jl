# env: base
# kind: throughput
# about: Small-vector math on tuples, which compiled code reduces to registers through
#   inlining and constant folding, and which the interpreter runs call by call.

# %% vectors
struct Vec3
    x::Float64; y::Float64; z::Float64
end
Base.:+(a::Vec3, b::Vec3) = Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
Base.:-(a::Vec3, b::Vec3) = Vec3(a.x - b.x, a.y - b.y, a.z - b.z)
Base.:*(s::Real, a::Vec3) = Vec3(s * a.x, s * a.y, s * a.z)
dot(a::Vec3, b::Vec3) = a.x * b.x + a.y * b.y + a.z * b.z
cross(a::Vec3, b::Vec3) = Vec3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
nrm(a) = sqrt(dot(a, a))

# %% integrate
function spin(n)
    ω = Vec3(0.1, 0.7, 0.3)
    r = Vec3(1.0, 0.0, 0.0)
    for _ in 1:n
        r = r + 1e-4 * cross(ω, r)
        r = (1 / nrm(r)) * r
    end
    return r
end
spin(20_000_000)

# %% ntuples
poly(t::NTuple{N,Float64}, x) where {N} = evalpoly(x, t)
sum(poly((1.0, -2.0, 0.5, 0.25, -0.125), x) for x in range(0, 1; length=10_000_000))
