# env: base
# kind: throughput
# mode: script
# about: Numerical script: Monte Carlo estimates in loops, each run once.

# %% pi
using Random
function estimate_pi(rng, n)
    hits = 0
    for _ in 1:n
        x, y = rand(rng), rand(rng)
        hits += x^2 + y^2 <= 1
    end
    return 4hits / n
end
estimate_pi(Xoshiro(3), 50_000_000)

# %% random walk
function walk(rng, steps)
    pos = 0
    farthest = 0
    for _ in 1:steps
        pos += rand(rng, (-1, 1))
        farthest = max(farthest, abs(pos))
    end
    return farthest
end
[walk(Xoshiro(i), 1_000_000) for i in 1:20]

# %% top-level loop
total = 0.0
for i in 1:2_000_000
    global total += sin(i) / i
end
total
