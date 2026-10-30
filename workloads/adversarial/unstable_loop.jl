# env: base
# kind: throughput
# about: A type-unstable accumulation loop, run once at length; the loop's types settle late.

# %% unstable
function accumulate_mixed(n)
    acc = 0
    for i in 1:n
        acc += i % 3 == 0 ? 0.5 : 1
        if i == n ÷ 2
            acc = big(acc)
        end
    end
    return acc
end
accumulate_mixed(2_000_000)
