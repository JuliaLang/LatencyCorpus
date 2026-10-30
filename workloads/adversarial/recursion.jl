# env: base
# kind: mixed
# about: Recursive and memoized computations, as in puzzle solutions.

# %% fib
fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
fib(27)

# %% memo
const memo = Dict{Tuple{Int,Int},Int}()
function paths(r, c)
    (r == 0 || c == 0) && return 1
    get!(memo, (r, c)) do
        paths(r - 1, c) + paths(r, c - 1)
    end
end
paths(16, 16)

# %% knapsack
function knapsack(weights, values, cap)
    best = zeros(Int, cap + 1)
    for (w, v) in zip(weights, values), c in cap:-1:w
        best[c+1] = max(best[c+1], best[c-w+1] + v)
    end
    return best[end]
end
knapsack(collect(1:200), collect(200:-1:1) .* 3, 5000)
