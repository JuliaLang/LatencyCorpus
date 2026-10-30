# Run BaseBenchmarks groups in this process and save the results:
#
#     julia --project=envs/bench [--tiered=yes] runner/basebench.jl <out.json> <seconds> group...
#
# Each benchmark gets `seconds` of sampling after BenchmarkTools' own tuning. Under tiering,
# a benchmark's code starts interpreted and is compiled once hot, so its minimum time should
# match an untiered run's: compare the saved results with runner/compare_bench.jl.
using BaseBenchmarks, BenchmarkTools

function main(out, seconds, groups)
    t0 = time()
    for g in groups
        BaseBenchmarks.load!(g; tune=false)
    end
    suite = BaseBenchmarks.SUITE
    for b in BenchmarkTools.leaves(suite)
        b[2].params.seconds = seconds
    end
    t1 = time()
    tune!(suite)
    t2 = time()
    results = run(suite; verbose=false)
    t3 = time()
    BenchmarkTools.save(out, results)
    println("load $(round(t1 - t0; digits=1))s, tune $(round(t2 - t1; digits=1))s, ",
        "run $(round(t3 - t2; digits=1))s, $(length(BenchmarkTools.leaves(results))) benchmarks")
end

main(ARGS[1], parse(Float64, ARGS[2]), ARGS[3:end])
