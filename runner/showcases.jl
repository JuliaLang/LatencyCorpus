# List the cells where tiered execution turns a slow interactive step into a quick one:
#
#     julia runner/showcases.jl [--base MODE] [--new MODE] [--min S] [--ratio R] <results dir>...
#
# prints a Markdown table of the cells that take at least `--min` seconds (default 1) in mode
# `--base` (default `master`) and run at least `--ratio` times (default 4) faster in mode
# `--new` (default `on`), fastest speedup first, with the first line of code of each cell.
# Times for repeated runs are averaged; the slowest run of each is shown too, since the first
# run in a fresh depot is often much slower.
using Statistics, Printf

function cellcode(workload, cell)
    dir = joinpath(@__DIR__, "..", "workloads")
    file = joinpath(dir, workload * ".jl")
    isfile(file) || (file = joinpath(dir, "docs", workload * ".jl"))
    isfile(file) || return ""
    here, first = false, ""
    for l in eachline(file)
        if startswith(l, "# %%")
            here = strip(l[5:end]) == cell  # see `read_cells` in cells.jl
        elseif here && !isempty(strip(l)) && !startswith(l, "#")
            startswith(l, r"using |import ") || return strip(l)
            isempty(first) && (first = strip(l))  # the cell only loads packages
        end
    end
    return first
end

function main(args)
    base, new, lo, ratio, dirs = "master", "on", 1.0, 4.0, String[]
    i = 1
    while i <= length(args)
        a = args[i]
        if a in ("--base", "--new", "--min", "--ratio")
            v = args[i += 1]
            a == "--base" ? (base = v) : a == "--new" ? (new = v) :
            a == "--min" ? (lo = parse(Float64, v)) : (ratio = parse(Float64, v))
        else
            push!(dirs, a)
        end
        i += 1
    end
    t = Dict{Tuple{String,String,String},Vector{Float64}}()
    for dir in dirs, l in eachline(joinpath(dir, "results.tsv"))
        f = split(l, '\t')
        (f[1] == "mode" || f[4] in ("process", "load")) && continue
        # leave out time in `using` and `import`, where recorded (see summarize.jl)
        load = length(f) in (11, 24) ? something(tryparse(Float64, f[11]), 0.0) : 0.0
        push!(get!(t, (f[1], f[3], f[4]), Float64[]), parse(Float64, f[5]) - load)
    end
    rows = []
    for ((m, w, c), a) in t
        m == base && haskey(t, (new, w, c)) || continue
        b = t[(new, w, c)]
        mean(a) >= lo && mean(a) / mean(b) >= ratio && push!(rows, (mean(a) / mean(b), w, c, a, b))
    end
    sort!(rows, by = first, rev = true)
    println("| speedup | $base s (slowest) | $new s (slowest) | workload | cell | code |")
    println("|---:|---:|---:|---|---|---|")
    for (r, w, c, a, b) in rows
        code = replace(cellcode(w, c), "|" => "\\|")
        @printf("| %.1f× | %.2f (%.1f) | %.2f (%.1f) | %s | %s | `%s` |\n", r, mean(a), maximum(a), mean(b), maximum(b), w, c, code)
    end
end

main(ARGS)
