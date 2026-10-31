# Summarize tiering's compile logs (`JULIA_TIER_LOG`, written by run.jl's `+log` modes):
#
#     julia runner/compilelog.jl [--top N] [--few K] <results dir>
#
# For each workload and mode, report what was compiled and why, what it cost, and how much
# of that cost went to roots that dispatch reached at most K times (default 2) after they were
# compiled: code compiled and then barely run is what tiering exists to avoid. Then list the
# N most expensive such roots of each workload. Loop continuations are not counted as
# barely run: entering one runs the rest of a loop compiled.
using Printf

struct Root
    id::Int
    why::String
    work::Int
    wall::Float64    # seconds
    infer::Float64
    cis::Int
    sig::String
    calls::Int       # dispatches after compiling; -1 for continuations
end

function readlog(file)
    roots = Dict{Int,Root}()
    calls = Dict{Int,Int}()
    for l in eachline(file)
        f = split(l, '\t')
        if f[1] == "R" && length(f) >= 10
            roots[parse(Int, f[2])] = Root(parse(Int, f[2]), f[3], parse(Int, f[4]),
                parse(Int, f[5]) / 1e9, parse(Int, f[6]) / 1e9, parse(Int, f[8]), f[10], -1)
        elseif f[1] == "C"
            calls[parse(Int, f[2])] = parse(Int, f[3])
        end
    end
    return [Root(r.id, r.why, r.work, r.wall, r.infer, r.cis, r.sig, get(calls, r.id, -1)) for r in values(roots)]
end

barely(r, few) = r.why != "continuation" && 0 <= r.calls <= few

function main(args)
    top, few, dir = 5, 2, ""
    i = 1
    while i <= length(args)
        a = args[i]
        a == "--top" ? (top = parse(Int, args[i += 1])) : a == "--few" ? (few = parse(Int, args[i += 1])) : (dir = a)
        i += 1
    end
    files = filter(endswith(".tsv"), readdir(joinpath(dir, "compile"); join=true))
    runs = Dict{Tuple{String,String},Vector{Root}}()  # (workload, mode)
    for f in files
        m = match(r"^(.*)-([^-]+)-(\d+)\.tsv$", basename(f))
        m === nothing && continue
        runs[(m[1], m[2])] = readlog(f)
    end
    modes = sort!(unique(last.(keys(runs))))
    println("Totals per mode (compile wall time in seconds; 'barely run' = dispatched to at most $few times afterwards):")
    @printf("  %-10s %6s %9s %9s %9s %8s\n", "mode", "runs", "roots", "wall", "barely", "share")
    for mode in modes
        rs = reduce(vcat, (v for ((w, m), v) in runs if m == mode); init=Root[])
        wall = sum(r -> r.wall, rs; init=0.0); b = sum(r -> r.wall, filter(r -> barely(r, few), rs); init=0.0)
        @printf("  %-10s %6d %9d %9.1f %9.1f %7.0f%%\n", mode, count(k -> k[2] == mode, keys(runs)), length(rs),
            wall, b, 100b / max(wall, 1e-9))
    end
    for mode in modes
        rs = reduce(vcat, (v for ((w, m), v) in runs if m == mode); init=Root[])
        println("\nWhy roots compiled, $mode:")
        whys = Dict{String,Tuple{Int,Float64,Float64}}()
        for r in rs
            n, w, b = get(whys, r.why, (0, 0.0, 0.0))
            whys[r.why] = (n + 1, w + r.wall, b + (barely(r, few) ? r.wall : 0.0))
        end
        @printf("  %-16s %8s %9s %9s\n", "why", "roots", "wall", "barely")
        for (why, (n, w, b)) in sort!(collect(whys); by=x -> -x[2][2])
            @printf("  %-16s %8d %9.1f %9.1f\n", why, n, w, b)
        end
    end
    println("\nPer workload:")
    for w in sort!(unique(first.(keys(runs))))
        print("  ", rpad(w, 50))
        for mode in modes
            rs = get(runs, (w, mode), nothing)
            rs === nothing && continue
            wall = sum(r -> r.wall, rs; init=0.0); b = sum(r -> r.wall, filter(r -> barely(r, few), rs); init=0.0)
            @printf("  %s %5d roots %6.1fs (%3.0f%% barely run)", mode, length(rs), wall, 100b / max(wall, 1e-9))
        end
        println()
    end
    for ((w, mode), rs) in sort!(collect(runs); by=first)
        bad = sort!(filter(r -> barely(r, few), rs); by=r -> -r.wall)
        isempty(bad) && continue
        println("\n$w, $mode: most expensive roots dispatched to at most $few times afterwards")
        for r in bad[1:min(top, end)]
            @printf("    %6.3fs  infer %6.3fs  %4d CIs  %-14s %7d stmts  %d calls  %s\n", r.wall, r.infer, r.cis,
                r.why, r.work, r.calls, first(r.sig, 140))
        end
    end
end

main(ARGS)
