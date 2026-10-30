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
#     workload  cell  wall_s  compile_s  recompile_s  alloc_bytes  ok  shown
#
# where compile_s is compilation time on this thread (`Base.cumulative_compile_time_ns`) and
# shown is a hash of what was displayed, to compare runs of deterministic workloads.
# A cell that throws is recorded with ok = false, its error is shown as the REPL would
# (that is part of its time), and the session carries on, as a REPL session does: the
# documentation of many packages shows errors on purpose.

import REPL

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

function run_cell(cell::Cell, path::String)
    # Pad with newlines so that line numbers in errors and backtraces match the file.
    code = "\n"^(cell.line - 1) * cell.code
    show_value = displays(cell.code)
    stats = Base.gc_num()
    c0 = Base.cumulative_compile_time_ns()
    t0 = time_ns()
    io = IOContext(IOBuffer(), :limit => true, :displaysize => (24, 80), :color => false)
    failure = nothing
    try
        value = include_string(REPL.softscope, Main, code, path)
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
    c1 = Base.cumulative_compile_time_ns()
    alloc = Base.GC_Diff(Base.gc_num(), stats).allocd
    ok = failure === nothing
    shown = string(hash(take!(io.io)); base=16)
    if !ok
        print(stderr, "cell $(cell.name): ")
        Base.invokelatest(showerror, stderr, failure...)
        println(stderr)
    end
    return (t1 - t0) / 1e9, (c1[1] - c0[1]) / 1e9, (c1[2] - c0[2]) / 1e9, alloc, ok, shown
end

function main(path::String, out::String)
    name = joinpath(basename(dirname(abspath(path))), splitext(basename(path))[1])
    Base.cumulative_compile_timing(true)
    open(out, "a") do io
        for cell in read_cells(path)
            wall, comp, recomp, alloc, ok, shown = run_cell(cell, path)
            println(io, join((name, cell.name, round(wall; digits=4), round(comp; digits=4),
                round(recomp; digits=4), alloc, ok, shown), '\t'))
            flush(io)
        end
    end
end

main(ARGS[1], ARGS[2])
