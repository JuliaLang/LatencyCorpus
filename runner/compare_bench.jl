# Compare two saved BaseBenchmarks runs by minimum time:
#
#     julia --project=envs/bench runner/compare_bench.jl <baseline.json> <tiered.json> [tolerance]
#
# Prints the distribution of tiered/baseline ratios and every benchmark outside the
# tolerance (default 1.10, i.e. 10%), slowest first.
using BenchmarkTools, Statistics

function main(a, b, tol=1.10)
    base = BenchmarkTools.load(a)[1]
    tier = BenchmarkTools.load(b)[1]
    rows = Tuple{String,Float64,Float64,Float64}[]
    for (k, ta) in BenchmarkTools.leaves(base)
        tb = try tier[k] catch; continue end
        ma, mb = minimum(ta).time, minimum(tb).time
        push!(rows, (join(k, "/"), ma, mb, mb / ma))
    end
    r = [x[4] for x in rows]
    println(length(rows), " benchmarks; tiered/baseline minimum time: median ",
        round(median(r); digits=3), ", geometric mean ", round(exp(mean(log.(r))); digits=3),
        ", worst ", round(maximum(r); digits=2), ", best ", round(minimum(r); digits=2))
    for x in sort!(filter(x -> x[4] > tol || x[4] < 1 / tol, rows); by=x -> -x[4])
        println(rpad(x[1], 90), lpad(round(x[4]; digits=2), 7), "   ",
            BenchmarkTools.prettytime(x[2]), " → ", BenchmarkTools.prettytime(x[3]))
    end
end

main(ARGS[1], ARGS[2], length(ARGS) > 2 ? parse(Float64, ARGS[3]) : 1.10)
