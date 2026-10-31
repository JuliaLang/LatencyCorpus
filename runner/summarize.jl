# Summarize a run.jl run that has both modes:
#
#     julia runner/summarize.jl [--base MODE] [--new MODE] <results dir>... [worst N]
#
# compares mode `--new` (default `on`) against `--base` (default `off`; use `master` for the
# baseline build). Several results directories are merged, so a stored baseline run can be
# compared with a later run of the build under test.
#
# Cells are judged by class (see `classify`), each by its own measure: interactive cells by
# perceptual bands, over-compilation by time and compile time, throughput as a pass or fail
# regression check. Ratios are new / base, so below 1 is faster. Times for repeated runs are
# averaged first.
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

# Each workload has a class in its `# kind:` header: `interactive`, `overcompile` or
# `throughput`. A cell that spends more than a second running in the base mode (wall time minus
# compile time) is judged as throughput whatever its workload's class, and a short cell in a
# throughput workload as interactive: someone is waiting for it. Cells that only load packages
# (`prelude` and `load`) are reported apart, since tiering can't change them.
const CLASSES = Dict{String,String}()

function workload_class(w)
    get!(CLASSES, w) do
        dir = joinpath(@__DIR__, "..", "workloads")
        file = joinpath(dir, w * ".jl")
        isfile(file) || (file = joinpath(dir, "docs", w * ".jl"))
        isfile(file) || return "interactive"
        for l in eachline(file)
            m = match(r"^# kind: *(\w+)", l)
            m === nothing || return String(m[1])
        end
        return "interactive"
    end
end

function classify(workload, cell, run)
    cell in ("prelude", "load") && return "loading"
    run > 1.0 && return "throughput"
    c = workload_class(workload)
    return c in ("overcompile", "throughput") ? (c == "throughput" ? "interactive" : c) : "interactive"
end

band(t) = t < 0.3 ? 1 : t < 1.0 ? 2 : 3
const BANDS = ("instant (<0.3s)", "acceptable (<1s)", "slow (>=1s)")

# Interactive: how each cell feels, in perceptual bands. Only cells that weren't already
# instant in the base mode count.
function interactive(cs, worst)
    slow = filter(x -> x[2] >= 0.3, cs)
    m = zeros(Int, 3, 3)
    for x in slow
        m[band(x[2]), band(x[3])] += 1
    end
    r = [x[3] / x[2] for x in slow]
    println("\nInteractive: $(length(slow)) cells not instant in $(BASE[]) (of $(length(cs))); median $(NEW[])/$(BASE[]) ",
        round(isempty(r) ? NaN : median(r); digits=3))
    @printf("  %-18s %18s %18s %18s\n", "$(BASE[]) \\ $(NEW[])", BANDS...)
    for i in 2:3
        @printf("  %-18s %18d %18d %18d\n", BANDS[i], m[i, :]...)
    end
    big = filter(x -> x[2] >= 1.0, slow)
    @printf("  of %d cells slow in %s: %d at least 10x faster, %d at least 4x faster, %d still slow\n",
        length(big), BASE[], count(x -> x[2] >= 10x[3], big), count(x -> x[2] >= 4x[3], big), count(x -> x[3] >= 1.0, big))
    worse = sort!(filter(x -> band(x[3]) > band(x[2]), cs); by=x -> x[2] - x[3])
    println("  cells that moved to a slower band: $(length(worse))")
    for x in worse[1:min(worst, end)]
        @printf("    %-80s %8.3f → %8.3f s\n", x[1], x[2], x[3])
    end
    stuck = sort!(filter(x -> x[3] >= 1.0, slow); by=x -> -x[3])
    println("  slowest cells in $(NEW[]):")
    for x in stuck[1:min(worst, end)]
        @printf("    %-80s %8.3f → %8.3f s\n", x[1], x[2], x[3])
    end
end

# Over-compilation: time and compile time; what was compiled is for the compile log.
function overcompile(cs, worst)
    a, b = sum(x[2] for x in cs; init=0.0), sum(x[3] for x in cs; init=0.0)
    ca, cb = sum(x[4] for x in cs; init=0.0), sum(x[5] for x in cs; init=0.0)
    @printf("\nOver-compilation: %d cells, %s %.1fs, %s %.1fs, ratio %.3f; compile time %.1fs → %.1fs\n",
        length(cs), BASE[], a, NEW[], b, b / a, ca, cb)
    bad = sort!(filter(x -> x[3] - x[2] > 0.05, cs); by=x -> x[2] - x[3])
    println("  slower by more than 50ms: $(length(bad)); worst:")
    for x in bad[1:min(worst, end)]
        @printf("    %-80s %8.3f → %8.3f s\n", x[1], x[2], x[3])
    end
end

# Throughput: a regression check, not something to optimize.
function throughput(cs, worst)
    a, b = sum(x[2] for x in cs; init=0.0), sum(x[3] for x in cs; init=0.0)
    bad = sort!(filter(x -> x[3] > 1.03x[2] && x[3] - x[2] > 0.05, cs); by=x -> x[2] - x[3])
    @printf("\nThroughput: %d cells, %s %.1fs, %s %.1fs, ratio %.3f: %s\n", length(cs), BASE[], a, NEW[], b, b / a,
        b <= 1.03a ? "pass" : "FAIL")
    println("  cells more than 3% slower: $(length(bad)); worst:")
    for x in bad[1:min(worst, end)]
        @printf("    %-80s %8.3f → %8.3f s  (%+.0f%%)\n", x[1], x[2], x[3], 100(x[3] / x[2] - 1))
    end
end

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

    # Cells, judged by class (see `classify`)
    cells = Dict(c => Tuple{String,Float64,Float64,Float64,Float64}[] for c in ("interactive", "overcompile", "throughput", "loading"))
    mismatches = String[]
    for k in keys(rows)
        k[1] == BASE[] && k[3] != "process" || continue
        kon = (NEW[], k[2], k[3])
        haskey(rows, kon) || continue
        a, b = rows[k], rows[kon]
        off, on = avg(a, r -> r.wall), avg(b, r -> r.wall)
        class = classify(k[2], k[3], off - avg(a, r -> r.compile))
        push!(cells[class], ("$(k[2]) | $(k[3])", off, on, avg(a, r -> r.compile), avg(b, r -> r.compile)))
        all(r -> r.ok, a) && all(r -> r.ok, b) && a[1].shown != b[1].shown && push!(mismatches, "$(k[2]) | $(k[3])")
    end
    interactive(cells["interactive"], worst)
    overcompile(cells["overcompile"], worst)
    throughput(cells["throughput"], worst)
    ld = cells["loading"]
    @printf("\nLoading cells (tiering can't change these): %d, %s %.1fs, %s %.1fs\n",
        length(ld), BASE[], sum(x[2] for x in ld; init=0.0), NEW[], sum(x[3] for x in ld; init=0.0))
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
