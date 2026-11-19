# Run one workload in this process, a cell at a time, the way a REPL session would:
#
#     julia --project=envs/<env> runner/cells.jl <workload.jl> <results.tsv>
#
# A workload is a Julia file split into cells by lines starting with `# %%`; the rest of
# such a line names the cell. Each cell is evaluated in `Main`, with the REPL's soft scope
# rules, and, unless its code ends with `;`, its value is shown as the REPL would (`show`
# with MIME"text/plain"), since displaying results is part of what an interactive user
# waits for. Values that can be shown as PNG, such as plots, are rendered as PNG instead,
# as an IDE or notebook displays them. For each cell this appends a line to the results file:
#
#     workload  cell  wall_s  compile_s  recompile_s  alloc_bytes  ok  shown  load_s
#
# where compile_s is compilation time on this thread (`Base.cumulative_compile_time_ns`),
# shown is a hash of what was displayed, to compare runs of deterministic workloads, and
# load_s is the time spent in the cell's top-level `using` and `import` statements, which
# tiering cannot change.
# On Julia builds that count time per phase of compilation, the line goes on with the
# change in each of those counters (see `phase_names`) over the cell.
# A cell that throws is recorded with ok = false, its error is shown as the REPL would
# (that is part of its time), and the session carries on, as a REPL session does: the
# documentation of many packages shows errors on purpose.
# The global random number generator is seeded before the first cell, so that workloads
# that draw random numbers take the same path, and compile the same code, in every run.
# Where Julia has a JIT delay (`JULIA_JIT_DELAY`), it starts with each cell, as it does with
# each REPL input.

import REPL
import Random
include(joinpath(@__DIR__, "perfcounters.jl"))
using .PerfCounters

struct Cell
    name::String
    line::Int
    code::String
end

# Whether `code` has anything besides comments and blank lines.
has_code(code) = any(l -> !isempty(strip(l)) && !startswith(lstrip(l), '#'), eachline(IOBuffer(code)))

function read_cells(path::String)
    cells = Cell[]
    name, line, buf = "prelude", 1, IOBuffer()
    for (i, l) in enumerate(eachline(path))
        if startswith(l, "# %%")
            code = String(take!(buf))
            has_code(code) && push!(cells, Cell(name, line, code))
            name = strip(l[5:end])
            name = isempty(name) ? "cell$(length(cells) + 1)" : String(name)
            line = i + 1
        else
            println(buf, l)
        end
    end
    code = String(take!(buf))
    has_code(code) && push!(cells, Cell(name, line, code))
    return cells
end

# Whether the REPL would display the value of `code`: not if it ends with `;`.
function displays(code::String)
    s = rstrip(code)
    while true
        # drop trailing comment lines
        i = findlast('\n', s)
        last = i === nothing ? s : s[i+1:end]
        if startswith(lstrip(last), "#") && i !== nothing
            s = rstrip(s[1:i-1])
        else
            break
        end
    end
    return !endswith(s, ';')
end

# Process-wide compilation counters, where this Julia has them: the runtime's
# `jl_compile_stats` (times in ns), then tiering's time spent widening and compiling loop
# continuations, and the number compiled.
const phase_names = ("infer_s", "infer_n", "emit_s", "emit_n", "emit_cis", "obj_s", "obj_n",
    "llvm_s", "llvm_n", "link_s", "widen_s", "cont_s", "cont_n")
const phase_ptr = try
    cglobal(:jl_compile_stats, UInt64)
catch
    nothing
end

function phase_counters()
    phase_ptr === nothing && return Float64[]
    c = Float64[unsafe_load(phase_ptr, i) for i in 1:10]
    t = isdefined(Base, :Tiered) && length(Base.Tiered.stats) >= 4 ? Base.Tiered.stats : zeros(Int, 4)
    append!(c, (t[3], t[4], t[1]))
    for i in (1, 3, 6, 8, 10, 11, 12)
        c[i] /= 1e9
    end
    return c
end

const start_jit_delay = isdefined(Base, :Tiered) && isdefined(Base.Tiered, :start_jit_delay) ?
    Base.Tiered.start_jit_delay : () -> nothing
# Marks in the compile trace (`JULIA_COMPILE_TRACE`), where the build has one.
const trace_mark = isdefined(Base, :Tiered) && isdefined(Base.Tiered, :trace_mark) ?
    Base.Tiered.trace_mark : (_) -> nothing

isload(ex) = Meta.isexpr(ex, (:using, :import))

# Evaluate `code` as `include_string` with the REPL's soft scope would, a top-level
# statement at a time, and return its value and the time spent in `using` and `import`.
function eval_cell(code::String, path::String)
    ex = Meta.parseall(code; filename=path)
    value, load = nothing, 0.0
    for st in ex.args
        if st isa LineNumberNode
            continue
        elseif Meta.isexpr(st, :error) || Meta.isexpr(st, :incomplete)
            Core.eval(Main, st)  # throws the parse error
        end
        t = time_ns()
        isload(st) && trace_mark("load")
        value = Core.eval(Main, REPL.softscope(st))
        isload(st) && (trace_mark("loaded"); load += (time_ns() - t) / 1e9)
    end
    return value, load
end

function run_cell(cell::Cell, path::String)
    # Pad with newlines so that line numbers in errors and backtraces match the file.
    code = "\n"^(cell.line - 1) * cell.code
    show_value = displays(cell.code)
    stats = Base.gc_num()
    pc0 = PERF[] === nothing ? nothing : vcat(read_counters(PERF[]), process_cpu()...)
    c0 = Base.cumulative_compile_time_ns()
    p0 = phase_counters()
    t0 = time_ns()
    io = IOContext(IOBuffer(), :limit => true, :displaysize => (24, 80), :color => false)
    failure = nothing
    load = 0.0
    trace_mark("cell " * cell.name)
    start_jit_delay()
    try
        value, load = eval_cell(code, path)
        if show_value && value !== nothing
            # Like the REPL, display in the latest world, which sees what the cell loaded.
            # Render what has an image form (plots, figures) as an IDE or notebook would.
            mime = Base.invokelatest(showable, MIME"image/png"(), value) ? MIME"image/png"() :
                MIME"text/plain"()
            Base.invokelatest(show, io, mime, value)
        end
    catch err
        failure = (err, catch_backtrace())
        Base.invokelatest(showerror, io, failure...)
    end
    t1 = time_ns()
    trace_mark("end " * cell.name)
    c1 = Base.cumulative_compile_time_ns()
    phases = round.(phase_counters() .- p0; digits=4)
    pc1 = PERF[] === nothing ? nothing : vcat(read_counters(PERF[]), process_cpu()...)
    gcdiff = Base.GC_Diff(Base.gc_num(), stats)
    alloc = gcdiff.allocd
    # GC time per cell, where asked for (CORPUS_GC_LOG=<file>): workload, cell, seconds, pauses
    gclog = get(ENV, "CORPUS_GC_LOG", "")
    isempty(gclog) || open(gclog, "a") do f
        println(f, path, '\t', cell.name, '\t', gcdiff.total_time / 1e9, '\t', gcdiff.pause)
    end
    # this thread's performance counters per cell, where asked for (CORPUS_PERF_LOG=<file>),
    # then the process's user and system CPU seconds:
    # workload, cell, then the change in each of `counter_names()`
    perflog = get(ENV, "CORPUS_PERF_LOG", "")
    isempty(perflog) || pc0 === nothing || open(perflog, "a") do f
        d = pc1 .- pc0
        println(f, path, '\t', cell.name, '\t', join(round.(Int, d[1:end-2]), '\t'), '\t',
                round(d[end-1]; digits=4), '\t', round(d[end]; digits=4))
    end
    ok = failure === nothing
    shown = string(hash(take!(io.io)); base=16)
    if !ok
        print(stderr, "cell $(cell.name): ")
        Base.invokelatest(showerror, stderr, failure...)
        println(stderr)
    end
    return (t1 - t0) / 1e9, (c1[1] - c0[1]) / 1e9, (c1[2] - c0[2]) / 1e9, alloc, ok, shown, load, phases
end

# Opened before the first cell, where the counters can be (see perfcounters.jl).
const PERF = Ref{Union{Nothing,PerfCounters.Counters}}(nothing)

function main(path::String, out::String)
    isempty(get(ENV, "CORPUS_PERF_LOG", "")) || (PERF[] = open_counters())
    # Compile the code that measures a cell before the first one is measured: a build that
    # compiles a callee only when it is first called would otherwise compile it in that cell.
    PERF[] === nothing || vcat(read_counters(PERF[]), process_cpu()...)
    eval_cell("nothing", path)
    name = joinpath(basename(dirname(abspath(path))), splitext(basename(path))[1])
    Base.cumulative_compile_timing(true)
    Random.seed!(0)
    # A REPL user's think time between inputs (CORPUS_THINK, seconds; see run.jl --think),
    # which is in no cell's time: work the session left running in the background, such as
    # compiling, goes on meanwhile, as it would while the user reads and types.
    think = parse(Float64, get(ENV, "CORPUS_THINK", "0"))
    open(out, "a") do io
        for (i, cell) in enumerate(read_cells(path))
            i > 1 && think > 0 && sleep(think)
            wall, comp, recomp, alloc, ok, shown, load, phases = run_cell(cell, path)
            println(io, join((name, cell.name, round(wall; digits=4), round(comp; digits=4),
                round(recomp; digits=4), alloc, ok, shown, round(load; digits=4), phases...), '\t'))
            flush(io)
        end
    end
    # what compiling each interpreted specialization would have cost (see run.jl, rtrace)
    if get(ENV, "CORPUS_COMPILE_INTERPRETED", "") == "1" && isdefined(Base, :Tiered) &&
            isdefined(Base.Tiered, :trace_compile_interpreted)
        trace_mark("compile interpreted")
        Base.Tiered.trace_compile_interpreted()
        trace_mark("compiled interpreted")
    end
end

main(ARGS[1], ARGS[2])
