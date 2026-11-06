# Run corpus workloads in fresh processes, with tiering off and on:
#
#     julia runner/run.jl [--julia PATH] [--master PATH] [--modes off,on] [--reps N]
#                         [--timeout S] [--jobs N] [--out DIR] workload_or_dir...
#
# Modes `off` and `on` run the Julia under test (`--julia`) without and with tiering; mode
# `master` runs the baseline build (`--master`, by default ~/dev/julia-master), which is
# what comparisons should be against. Baseline results stay valid until master is updated,
# so they need not be rerun with every build under test.
#
# Each run starts a new Julia process in an empty temporary directory, using the
# environment named by the workload's `# env:` header line and any Julia options in its
# `# args:` line, and records the per-cell
# timings from cells.jl plus a `process` row with the wall time of the whole process
# (startup, package loading and exit included). Results are appended to
# <out>/results.tsv with the columns
#
#     mode  rep  workload  cell  wall_s  compile_s  recompile_s  alloc_bytes  ok  shown  load_s
#
# and each run's output goes to <out>/logs/<workload>-<mode>-<rep>.log. `--jobs` runs that
# many processes at once, which is for checking that workloads run: timings need one at a
# time.

const ROOT = dirname(@__DIR__)
# Each mode: Julia options and environment variables. A mode name ending in `+log` runs the
# mode before it with tiering's compile log (`JULIA_TIER_LOG`) written to
# <out>/compile/<workload>-<mode>-<rep>.tsv (see compilelog.jl).
const TIERED = ["--tiered=yes"]
const MODES = Dict(
    "off" => (String[], Dict{String,String}()),
    "on" => (TIERED, Dict{String,String}()),
    # tiering's defaults, but compiling on the thread that spends a budget, not in the background
    "onsync" => (TIERED, Dict("JULIA_TIER_BACKGROUND" => "0")),
    "oncold" => (TIERED, Dict("JULIA_OBJCACHE" => "0")),
    "master" => (String[], Dict{String,String}()),
    "mastercold" => (String[], Dict("JULIA_OBJCACHE" => "0")),
    "delay500" => (TIERED, Dict("JULIA_JIT_DELAY" => "500")),
    "delay1000" => (TIERED, Dict("JULIA_JIT_DELAY" => "1000")),
    "cost" => (TIERED, Dict("JULIA_TIER_CI_COST" => "30000")),
    "cost1000" => (TIERED, Dict("JULIA_TIER_CI_COST" => "30000", "JULIA_JIT_DELAY" => "1000")),
    "inbounds" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1")),
    # the budget scaled by the method's lowered size (JULIA_TIER_STMT_COST), with `@inbounds`
    # code interpreted
    "sized300" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_STMT_COST" => "300")),
    "sized100" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_STMT_COST" => "100")),
    "sized300cold" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_STMT_COST" => "300",
                                    "JULIA_OBJCACHE" => "0")),
    # Compile traces (`JULIA_COMPILE_TRACE`, written to <out>/trace/; see trace.jl): what
    # compiling costs, with no object cache so that every module pays for LLVM, and with
    # it; how often compiled code runs; and what interpreting costs, with budgets large
    # enough that hot code stays interpreted long enough to measure.
    "trace" => (String[], Dict("JULIA_OBJCACHE" => "0")),
    "wtrace" => (String[], Dict{String,String}()),
    "counts" => (String[], Dict("JULIA_COMPILE_TRACE_COUNTS" => "1")),
    "itrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_WORK" => "1000000",
                              "JULIA_TIER_LOOP" => "1000000")),
    # itrace, and then what compiling each specialization that ran interpreted costs
    # (see `Tiered.trace_compile_interpreted`), which can be much more or less than
    # compiling it from compiled callers, as the trace mode does, and what each inlines
    "rtrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_WORK" => "1000000",
                              "JULIA_TIER_LOOP" => "1000000", "CORPUS_COMPILE_INTERPRETED" => "1",
                              "JULIA_COMPILE_TRACE_COUNTS" => "2",
                              "JULIA_OBJCACHE" => "0")),
    # tiering with `@inbounds` code interpreted (the settled rule), traced with a warm object
    # cache, to see where interactive cells spend their time
    "inbtrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1")),
    # budgets that count what callees interpret (JULIA_TIER_INCLUSIVE): fixed, only through
    # call sites that reached one callee (JULIA_TIER_MONO), and scaled by what compiling the
    # callees with the caller would cost (JULIA_TIER_SUBTREE_COST)
    "incl" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1")),
    "inclmono" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1",
        "JULIA_TIER_MONO" => "1")),
    "inclsub300" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1",
        "JULIA_TIER_SUBTREE_COST" => "300")),
    "inclsub100" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1",
        "JULIA_TIER_SUBTREE_COST" => "100")),
    # budgets capped at k statements per lowered statement (JULIA_TIER_SMALL_COST), so small
    # methods compile sooner, on top of inbounds and of inclsub300
    "small100" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_SMALL_COST" => "100")),
    "small1000" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_SMALL_COST" => "1000")),
    "inclsmall100" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1",
        "JULIA_TIER_SUBTREE_COST" => "300", "JULIA_TIER_SMALL_COST" => "100")),
    "incltrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1")),
    "inclsubtrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_INCLUSIVE" => "1",
        "JULIA_TIER_SUBTREE_COST" => "300")),
    # tiering as it is, traced, to see what it compiles
    "ontrace" => (TIERED, Dict{String,String}()),
    "sizedcounts" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_STMT_COST" => "300",
                                   "JULIA_COMPILE_TRACE_COUNTS" => "1")),
    "sizedtrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_STMT_COST" => "300",
                                  "JULIA_OBJCACHE" => "0")),
)
const TRACED = ("trace", "wtrace", "inbtrace", "counts", "itrace", "rtrace", "ontrace", "sizedtrace", "sizedcounts", "incltrace", "inclsubtrace")
const OUTPUT_LOCK = ReentrantLock()

function header(path::String, key::String)
    for l in eachline(path)
        m = match(Regex("^#\\s*$key:\\s*(.*?)\\s*\$"), l)
        m === nothing || return String(m[1])
        startswith(l, "#") || isempty(strip(l)) || break
    end
    return nothing
end

# A workload's name: its file name, qualified by its directory (`makie/index`), since
# documentation pages of different packages share names.
workload_name(path) = joinpath(basename(dirname(abspath(path))), splitext(basename(path))[1])

function workloads(args::Vector{String})
    files = String[]
    for a in args
        if isdir(a)
            for (dir, _, fs) in walkdir(a), f in sort(fs)
                endswith(f, ".jl") && push!(files, joinpath(dir, f))
            end
        else
            push!(files, a)
        end
    end
    return files
end

objcache_dir(out, mode) = joinpath(abspath(out), "objcache", mode)

function run_one(julia, path, mode, rep, timeout, out)
    base_mode = replace(mode, r"\+log$" => "")
    julia = julia[startswith(base_mode, "master") ? 2 : 1]
    opts, mode_env = MODES[base_mode]
    env = something(header(path, "env"), "base")
    name = workload_name(path)
    cells = joinpath(mktempdir(), "cells.tsv")
    log = joinpath(out, "logs", replace(name, '/' => '-') * "-$mode-$rep.log")
    args = split(something(header(path, "args"), ""))
    cmd = `timeout $timeout $julia --startup-file=no $opts $args --project=$(joinpath(ROOT, "envs", env))
           $(joinpath(ROOT, "runner", "cells.jl")) $(abspath(path)) $cells`
    cmd = setenv(cmd, merge(ENV, Dict(
        "JULIA_DEPOT_PATH" => get(ENV, "CORPUS_DEPOT", joinpath(ROOT, "depot")),
        "GKSwstype" => "100",            # GR without a display
        "JULIA_PKG_PRECOMPILE_AUTO" => "0",
        "CORPUS_DATA" => joinpath(ROOT, "data"),
    ), mode_env, endswith(mode, "+log") ? Dict("JULIA_TIER_LOG" =>
        joinpath(abspath(out), "compile", replace(name, '/' => '-') * "-$base_mode-$rep.tsv")) : Dict(),
        base_mode in TRACED ? Dict("JULIA_COMPILE_TRACE" =>
        joinpath(abspath(out), "trace", replace(name, '/' => '-') * "-$base_mode-$rep.trace")) : Dict(),
        # GC time per cell (see cells.jl), in a file per run, where asked for
        haskey(ENV, "CORPUS_GC_LOG") ? Dict("CORPUS_GC_LOG" =>
        joinpath(abspath(out), "gc", replace(name, '/' => '-') * "-$mode-$rep.tsv")) : Dict(),
        # and the main thread's performance counters per cell (see perfcounters.jl)
        haskey(ENV, "CORPUS_PERF_LOG") ? Dict("CORPUS_PERF_LOG" =>
        joinpath(abspath(out), "perf", replace(name, '/' => '-') * "-$mode-$rep.tsv")) : Dict(),
        # An object cache per mode, large enough that nothing is evicted: a cache shared by
        # every mode and build holds less than the corpus compiles, so what hits depended on
        # what ran before. The first repetition fills it, as a user's first session does.
        get(ENV, "CORPUS_SHARED_OBJCACHE", "") == "1" ? Dict() : Dict(
        "JULIA_OBJCACHE_PATH" => objcache_dir(out, base_mode),
        "JULIA_OBJCACHE_CAPACITY" => string(32 << 30)));
        dir=dirname(cells))
    t0 = time()
    proc = run(pipeline(ignorestatus(cmd); stdout=log, stderr=log))
    wall = time() - t0
    rows = isfile(cells) ? readlines(cells) : String[]
    failed = count(r -> split(r, '\t')[7] == "false", rows)
    # `timeout` passes on a signal that killed Julia by dying of it itself
    status = proc.exitcode == 124 ? "timeout" : proc.exitcode != 0 ? "exit$(proc.exitcode)" :
        proc.termsignal != 0 ? "signal$(proc.termsignal)" :
        failed == 0 ? "ok" : "$failed/$(length(rows)) cells failed"
    @lock OUTPUT_LOCK open(joinpath(out, "results.tsv"), "a") do io
        for r in rows
            println(io, mode, '\t', rep, '\t', r)
        end
        println(io, join((mode, rep, name, "process", round(wall; digits=4), "", "", "", status, ""), '\t'))
    end
    @lock OUTPUT_LOCK println(rpad(name, 48), " ", rpad(mode, 9), "rep $rep  ", lpad(round(wall; digits=2), 7), "s  ", status)
end

function main(args)
    julia = joinpath(homedir(), "dev", "julia", "usr", "bin", "julia")
    master = joinpath(homedir(), "dev", "julia-master", "usr", "bin", "julia")
    modes, reps, timeout, jobs = ["off", "on"], 1, 1800, 1
    out = joinpath(ROOT, "results", Libc.strftime("%Y%m%d-%H%M%S", time()))
    paths = String[]
    i = 1
    while i <= length(args)
        a = args[i]
        if a == "--julia"; julia = args[i += 1]
        elseif a == "--master"; master = args[i += 1]
        elseif a == "--modes"; modes = split(args[i += 1], ',')
        elseif a == "--reps"; reps = parse(Int, args[i += 1])
        elseif a == "--timeout"; timeout = parse(Int, args[i += 1])
        elseif a == "--out"; out = args[i += 1]
        elseif a == "--jobs"; jobs = parse(Int, args[i += 1])
        else push!(paths, a)
        end
        i += 1
    end
    mkpath(joinpath(out, "logs"))
    any(m -> endswith(m, "+log"), modes) && mkpath(joinpath(out, "compile"))
    any(m -> replace(m, r"\+log$" => "") in TRACED, modes) && mkpath(joinpath(out, "trace"))
    haskey(ENV, "CORPUS_GC_LOG") && mkpath(joinpath(out, "gc"))
    haskey(ENV, "CORPUS_PERF_LOG") && mkpath(joinpath(out, "perf"))
    get(ENV, "CORPUS_SHARED_OBJCACHE", "") == "1" ||
        foreach(m -> mkpath(objcache_dir(out, replace(m, r"\+log$" => ""))), modes)
    # Alternate modes within each repetition, so drift in machine load affects both alike.
    runs = [(path, mode, rep) for rep in 1:reps for path in workloads(paths) for mode in modes]
    asyncmap(r -> run_one((julia, master), r..., timeout, out), runs; ntasks=jobs)
    println("results in ", out)
end

main(ARGS)
