# Summarize a run.jl run that has both modes:
#
#     julia runner/summarize.jl [--base MODE] [--new MODE] <results dir>... [worst N]
#
# compares mode `--new` (default `on`) against `--base` (default `off`; use `master` for the
# baseline build). Several results directories are merged, so a stored baseline run can be
# compared with a later run of the build under test.
#
# Cells are classed by the untiered run: a throughput cell spends more than a second running
# (wall time minus compile time), a latency cell less. Ratios are tiered / untiered, so
# below 1 is faster with tiering. Times for repeated runs are averaged first.
using Statistics, Printf

struct Row
    wall::Float64
    compile::Float64
    ok::Bool
    shown::String
end

const BASE = Ref("off")
const NEW = Ref("on")

function load(dirs)
    rows = Dict{Tuple{String,String,String},Vector{Row}}()  # (mode, workload, cell)
    status = Dict{Tuple{String,String},String}()
    for dir in dirs, l in eachline(joinpath(dir, "results.tsv"))
        f = split(l, '\t')
        mode, workload, cell = f[1], f[3], f[4]
        if cell == "process"
            status[(mode, workload)] = f[9]
        end
        push!(get!(rows, (mode, workload, cell), Row[]),
            Row(parse(Float64, f[5]), something(tryparse(Float64, f[6]), 0.0), f[9] in ("true", "ok"),
                length(f) >= 10 ? f[10] : ""))
    end
    return rows, status
end

avg(rs, f) = mean(f(r) for r in rs)
geomean(x) = isempty(x) ? NaN : exp(mean(log.(x)))
family(w) = split(w, '/')[1] == "docs" ? w : first(split(w, '/'))

function main(dirs, worst=15)
    rows, status = load(dirs)
    workloads = sort!(unique(k[2] for k in keys(rows) if k[1] == BASE[] && haskey(rows, (NEW[], k[2], k[3]))))
    # Process totals per family
    fam = Dict{String,Vector{Tuple{Float64,Float64}}}()
    for w in workloads
        haskey(rows, (NEW[], w, "process")) || continue
        off, on = avg(rows[(BASE[], w, "process")], r -> r.wall), avg(rows[(NEW[], w, "process")], r -> r.wall)
        push!(get!(fam, family(w), Tuple{Float64,Float64}[]), (off, on))
    end
    println("Whole processes (startup, loading, every cell, exit):")
    @printf("  %-14s %5s %10s %10s %8s %10s\n", "family", "n", "$(BASE[]) s", "$(NEW[]) s", "$(NEW[])/$(BASE[])", "geomean")
    tot_off = tot_on = 0.0
    for (f, v) in sort!(collect(fam); by=first)
        off, on = sum(first, v), sum(last, v)
        tot_off += off; tot_on += on
        @printf("  %-14s %5d %10.1f %10.1f %8.3f %10.3f\n", f, length(v), off, on, on / off,
            geomean([b / a for (a, b) in v]))
    end
    @printf("  %-14s %5d %10.1f %10.1f %8.3f\n", "all", sum(length, values(fam)), tot_off, tot_on, tot_on / tot_off)

    # Cells
    lat, thr = Tuple{String,Float64,Float64}[], Tuple{String,Float64,Float64}[]
    mismatches = String[]
    for k in keys(rows)
        k[1] == BASE[] && k[3] != "process" || continue
        kon = (NEW[], k[2], k[3])
        haskey(rows, kon) || continue
        a, b = rows[k], rows[kon]
        off, on = avg(a, r -> r.wall), avg(b, r -> r.wall)
        run = off - avg(a, r -> r.compile)
        push!(run > 1.0 ? thr : lat, ("$(k[2]) | $(k[3])", off, on))
        all(r -> r.ok, a) && all(r -> r.ok, b) && a[1].shown != b[1].shown && push!(mismatches, "$(k[2]) | $(k[3])")
    end
    for (name, cs) in (("Latency cells", lat), ("Throughput cells", thr))
        r = [max(on, 1e-4) / max(off, 1e-4) for (_, off, on) in cs]
        println("\n$name: $(length(cs)), $(BASE[]) $(round(sum(x[2] for x in cs); digits=1))s, $(NEW[]) $(round(sum(x[3] for x in cs); digits=1))s, ",
            "geomean $(NEW[])/$(BASE[]) $(round(geomean(r); digits=3)), median $(round(median(r); digits=3))")
        # Slowdowns that matter in absolute terms
        bad = sort!(filter(x -> x[3] - x[2] > 0.05, cs); by=x -> x[2] - x[3])
        println("  slower by more than 50ms: $(length(bad)); worst:")
        for (n, off, on) in bad[1:min(worst, end)]
            @printf("    %-80s %8.3f → %8.3f s\n", n, off, on)
        end
    end
    failed = [w for w in workloads if get(status, (NEW[], w), "") != get(status, (BASE[], w), "")]
    println("\nWorkloads whose status differs between modes: ", isempty(failed) ? "none" : "")
    for w in failed
        println("    $w: $(BASE[]) $(status[(BASE[], w)]), $(NEW[]) $(status[(NEW[], w)])")
    end
    println("Cells whose shown output differs (expected for nondeterministic cells): $(length(mismatches))")
    for m in sort!(mismatches)[1:min(worst, end)]
        println("    ", m)
    end
end

function parse_args(args)
    dirs, worst = String[], 15
    i = 1
    while i <= length(args)
        a = args[i]
        if a == "--base"; BASE[] = args[i += 1]
        elseif a == "--new"; NEW[] = args[i += 1]
        elseif isdir(a); push!(dirs, a)
        else worst = parse(Int, a)
        end
        i += 1
    end
    return dirs, worst
end

main(parse_args(ARGS)...)
