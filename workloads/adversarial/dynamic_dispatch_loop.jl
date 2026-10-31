# env: base
# kind: throughput
# about: A hot loop over a heterogeneous container: every call is dynamically dispatched, so
#   each call crosses the tier boundary.

# %% shapes
abstract type Shape end
struct Circle <: Shape; r::Float64; end
struct Square <: Shape; s::Float64; end
struct Rect <: Shape; w::Float64; h::Float64; end
struct Tri <: Shape; b::Float64; h::Float64; end
area(c::Circle) = π * c.r^2
area(s::Square) = s.s^2
area(r::Rect) = r.w * r.h
area(t::Tri) = t.b * t.h / 2
perimeter(c::Circle) = 2π * c.r
perimeter(s::Square) = 4s.s
perimeter(r::Rect) = 2(r.w + r.h)
perimeter(t::Tri) = t.b + 2hypot(t.b / 2, t.h)

# %% build
using Random
rng = Xoshiro(10)
shapes = Shape[rand(rng, (Circle(rand(rng)), Square(rand(rng)), Rect(rand(rng), rand(rng)), Tri(rand(rng), rand(rng))))
               for _ in 1:2_000_000];

# %% totals
function totals(shapes)
    a = p = 0.0
    for s in shapes
        a += area(s)
        p += perimeter(s)
    end
    return a, p
end
totals(shapes)

# %% any vector
mixed = Any[1, 2.0, "three", 4//1, 5f0, big(6), 0x07, 'h', 9.0 + 0im]
describe(x) = string(typeof(x), ": ", x)
[describe(mixed[mod1(i, length(mixed))]) for i in 1:100_000] |> length
