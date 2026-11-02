# Evaluating tiering heuristics offline: simulate each candidate over every recorded
# workload (tracesim.jl) and score it per class of workload, against tiering off, by what
# that class is for:
#
#   interactive   snappy: the geometric mean of time over workloads, and the worst
#   overcompile   compiling nothing pointless: the geometric mean of compile time
#   throughput    no slower: the worst slowdown
#
# Usage: julia runner/tracesearch.jl <recording dir> <rtrace dir>

include(joinpath(@__DIR__, "tracesim.jl"))

# A heuristic that scales a specialization's budget by its method's lowered size, a proxy
# for what compiling it costs that tiering knows before compiling anything; methods using
# `@inbounds` (performance code, by their author's say) get `hint` times less.
function sized(; k=100, loop=20000, hint=1.0, inbounds=true, name="sized k=$k loop=$loop hint=$hint")
    Heuristic(name, loop) do s
        f = s.features
        f === nothing && return max(20000 - s.work, 0.0)
        needs_compiler(f; inbounds) && return 0.0
        b = k * max(f.nstmts, 1)
        occursin('I', f.flags) && (b /= hint)
        return max(b - s.work, 0.0)
    end
end

struct Score
    time::Float64       # predicted / off, over the workload's cells
    compile::Float64    # predicted compile / off compile
    roots::Int
end

function score(w::Workload, h::Heuristic, cache::Symbol)
    r = simulate(w, h; cache)
    t = sum((c.wall for c in values(r.cells)); init=0.0)
    c = sum((c.compile for c in values(r.cells)); init=0.0)
    off = values(w.off[cache])
    toff = sum((x[1] for x in off); init=0.0)
    coff = sum((x[2] for x in off); init=0.0)
    return Score(t / max(toff, 1e-3), c / max(coff, 1e-3), length(r.compiled))
end

function candidates()
    hs = Heuristic[current(), current(inbounds=true, name="current inbounds"), never, always]
    for work in (2_000, 5_000, 100_000, 1_000_000), loop in (2_000, 20_000, 200_000), inbounds in (false, true)
        push!(hs, current(; work, loop, inbounds, name="current work=$work loop=$loop inbounds=$inbounds"))
    end
    for k in (10, 30, 100, 300, 1000), loop in (2_000, 20_000, 200_000), hint in (1.0, 10.0)
        push!(hs, sized(; k, loop, hint))
    end
    return hs
end

function report(io::IO, wls, hs; caches=(:cold, :warm))
    for cache in caches
        println(io, "== $cache cache")
        rows = []
        for h in hs
            byclass = Dict{String,Vector{Score}}()
            for w in wls
                push!(get!(byclass, w.kind, Score[]), score(w, h, cache))
            end
            push!(rows, (h.name, byclass))
        end
        for kind in ("interactive", "overcompile", "throughput", "unknown")
            any(r -> haskey(r[2], kind), rows) || continue
            n = length(first(r[2][kind] for r in rows if haskey(r[2], kind)))
            println(io, "-- $kind ($n workloads): time geomean, worst; compile geomean; roots")
            sorted = sort(filter(r -> haskey(r[2], kind), rows),
                          by = r -> kind == "throughput" ? maximum(s.time for s in r[2][kind]) :
                                    kind == "overcompile" ? geomean(s.compile for s in r[2][kind]) :
                                    geomean(s.time for s in r[2][kind]))
            for (name, byclass) in sorted
                ss = byclass[kind]
                println(io, "  ", rpad(name, 52), lpad(round(geomean(s.time for s in ss), digits=3), 7),
                        lpad(round(maximum(s.time for s in ss), digits=2), 8),
                        lpad(round(geomean(s.compile for s in ss), digits=3), 8),
                        lpad(sum(s.roots for s in ss), 8))
            end
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    wls = load_all(ARGS[1]; rdir=ARGS[2])
    println(length(wls), " workloads")
    report(stdout, wls, candidates())
end
