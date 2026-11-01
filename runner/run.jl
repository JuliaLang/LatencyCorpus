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
    "oncold" => (TIERED, Dict("JULIA_OBJCACHE" => "0")),
    "master" => (String[], Dict{String,String}()),
    "delay500" => (TIERED, Dict("JULIA_JIT_DELAY" => "500")),
    "delay1000" => (TIERED, Dict("JULIA_JIT_DELAY" => "1000")),
    "cost" => (TIERED, Dict("JULIA_TIER_CI_COST" => "30000")),
    "cost1000" => (TIERED, Dict("JULIA_TIER_CI_COST" => "30000", "JULIA_JIT_DELAY" => "1000")),
    "inbounds" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1")),
    # Compile traces (`JULIA_COMPILE_TRACE`, written to <out>/trace/; see trace.jl): what
    # compiling costs, with no object cache so that every module pays for LLVM, and with
    # it; how often compiled code runs; and what interpreting costs, with budgets large
    # enough that hot code stays interpreted long enough to measure.
    "trace" => (String[], Dict("JULIA_OBJCACHE" => "0")),
    "wtrace" => (String[], Dict{String,String}()),
    "counts" => (String[], Dict("JULIA_COMPILE_TRACE_COUNTS" => "1")),
    "itrace" => (TIERED, Dict("JULIA_TIER_INBOUNDS" => "1", "JULIA_TIER_WORK" => "1000000",
                              "JULIA_TIER_LOOP" => "1000000")),
)
const TRACED = ("trace", "wtrace", "counts", "itrace")
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

function run_one(julia, path, mode, rep, timeout, out)
    base_mode = replace(mode, r"\+log$" => "")
    julia = julia[base_mode == "master" ? 2 : 1]
    opts, mode_env = MODES[base_mode]
    env = something(header(path, "env"), "base")
    name = workload_name(path)
    cells = joinpath(mktempdir(), "cells.tsv")
    log = joinpath(out, "logs", replace(name, '/' => '-') * "-$mode-$rep.log")
    args = split(something(header(path, "args"), ""))
    cmd = `timeout $timeout $julia --startup-file=no $opts $args --project=$(joinpath(ROOT, "envs", env))
           $(joinpath(ROOT, "runner", "cells.jl")) $(abspath(path)) $cells`
    cmd = setenv(cmd, merge(ENV, Dict(
        "JULIA_DEPOT_PATH" => joinpath(ROOT, "depot"),
        "GKSwstype" => "100",            # GR without a display
        "JULIA_PKG_PRECOMPILE_AUTO" => "0",
        "CORPUS_DATA" => joinpath(ROOT, "data"),
    ), mode_env, endswith(mode, "+log") ? Dict("JULIA_TIER_LOG" =>
        joinpath(abspath(out), "compile", replace(name, '/' => '-') * "-$base_mode-$rep.tsv")) : Dict(),
        base_mode in TRACED ? Dict("JULIA_COMPILE_TRACE" =>
        joinpath(abspath(out), "trace", replace(name, '/' => '-') * "-$base_mode-$rep.trace")) : Dict());
        dir=dirname(cells))
    t0 = time()
    proc = run(pipeline(ignorestatus(cmd); stdout=log, stderr=log))
    wall = time() - t0
    rows = isfile(cells) ? readlines(cells) : String[]
    failed = count(r -> split(r, '\t')[7] == "false", rows)
    status = proc.exitcode == 124 ? "timeout" : proc.exitcode != 0 ? "exit$(proc.exitcode)" :
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
    any(in(TRACED), modes) && mkpath(joinpath(out, "trace"))
    # Alternate modes within each repetition, so drift in machine load affects both alike.
    runs = [(path, mode, rep) for rep in 1:reps for path in workloads(paths) for mode in modes]
    asyncmap(r -> run_one((julia, master), r..., timeout, out), runs; ntasks=jobs)
    println("results in ", out)
end

main(ARGS)
