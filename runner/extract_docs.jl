# Turn the runnable examples in Documenter markdown into corpus workloads:
#
#     julia runner/extract_docs.jl [--prelude CODE] [--url URL] [--license URL] <env> <outdir> <docs dir or .md file>...
#
# Documenter runs `@example`, `@repl` and `@setup` blocks at docs-build time and checks
# `jldoctest` blocks; Makie's docs add `@figure` blocks, which are `@example` blocks that
# load CairoMakie and render a figure. Each page becomes one workload, its blocks in page
# order, as for someone working through the page in one REPL session: an
# `@example`/`@setup`/`@figure` block is one cell, and each input of a `@repl` block or a
# `julia>` prompt of a `jldoctest` is one cell. `--prelude` adds a first cell, for setup
# the docs build does implicitly (`using CairoMakie` for `@figure`). Workloads are written
# as <outdir>/<page>.jl with `env`, `source`, `license` and `kind` header lines; `kind` is
# left as `unknown`, to be set once the workload has been run. `--url` is the address of the
# docs directory at the version extracted from (each page's `source` is that followed by the
# page's path), and `--license` that of the license the documentation is under.

struct Block
    kind::Symbol     # :example, :setup, :figure, :repl or :doctest
    code::String
end

# Fenced code blocks of `path` that Documenter executes.
function blocks(path::String)
    out = Block[]
    lines = readlines(path)
    i = 1
    while i <= length(lines)
        m = match(r"^(\s*)(```+)\s*(@example|@repl|@setup|@figure|jldoctest)\b(.*)$", lines[i])
        if m === nothing
            i += 1
            continue
        end
        indent, fence, info, args = m[1], m[2], m[3], m[4]
        body = String[]
        i += 1
        while i <= length(lines) && !startswith(lstrip(lines[i]), fence)
            push!(body, chopprefix(lines[i], indent))
            i += 1
        end
        i += 1
        # Figures that need GLMakie's OpenGL backend can't run headless.
        occursin("GLMakie", args) && continue
        kind = info == "jldoctest" ? :doctest : Symbol(info[2:end])
        push!(out, Block(kind, join(body, '\n')))
    end
    return out
end

# The inputs of a REPL transcript (`julia> ...` with continuation lines indented to match).
function repl_inputs(code::String)
    inputs = String[]
    cur = nothing
    for l in split(code, '\n')
        if startswith(l, "julia> ")
            cur === nothing || push!(inputs, join(cur, '\n'))
            cur = [l[8:end]]
        elseif cur !== nothing && startswith(l, "       ")
            push!(cur, l[8:end])
        elseif cur !== nothing
            push!(inputs, join(cur, '\n'))
            cur = nothing
        end
    end
    cur === nothing || push!(inputs, join(cur, '\n'))
    return inputs
end

# The complete top-level expressions of `code`, as source text.
function expressions(code::String)
    ex = Meta.parseall(code)
    src = split(code, '\n')
    starts = [a.line for a in ex.args if a isa LineNumberNode]
    return [join(src[s:(i < length(starts) ? starts[i+1] - 1 : length(src))], '\n')
            for (i, s) in enumerate(starts)]
end

function cells(b::Block)
    b.kind === :repl && return expressions(b.code)
    b.kind === :doctest && return occursin("julia> ", b.code) ? repl_inputs(b.code) : String[]
    return [b.code]
end

# Cells that do something besides run the example: build documentation images with external
# tools, or write documentation files.
keep(c) = !isempty(strip(c)) && !occursin(r"run\(`|ansitoimg|pdflatex|`convert |save_docs_|Documenter", c)

slug(s) = strip(replace(lowercase(s), r"[^a-z0-9]+" => "_"), '_')

function extract(env::String, outdir::String, page::String, root::String, prelude, url, license)
    cs = [c for b in blocks(page) for c in cells(b) if keep(c)]
    isempty(cs) && return 0
    rel = relpath(page, root)
    open(joinpath(outdir, slug(splitext(rel)[1]) * ".jl"), "w") do io
        println(io, "# env: ", env)
        println(io, "# kind: unknown")
        println(io, "# source: ", something(url, ""), rel)
        license === nothing || println(io, "# license: ", license)
        prelude === nothing || println(io, "\n# %% prelude\n", prelude)
        for (i, c) in enumerate(cs)
            println(io, "\n# %% ", i)
            println(io, rstrip(c))
        end
    end
    return 1
end

function main(args)
    prelude = url = license = nothing
    while startswith(args[1], "--")
        opt, val, args = args[1], args[2], args[3:end]
        if opt == "--prelude"; prelude = val
        elseif opt == "--url"; url = val
        elseif opt == "--license"; license = val
        else error("unknown option: ", opt)
        end
    end
    env, outdir = args[1], args[2]
    mkpath(outdir)
    total = 0
    for a in args[3:end]
        if isdir(a)
            for (dir, _, fs) in walkdir(a), f in sort(fs)
                endswith(f, ".md") && (total += extract(env, outdir, joinpath(dir, f), a, prelude, url, license))
            end
        else
            total += extract(env, outdir, a, dirname(a), prelude, url, license)
        end
    end
    println("wrote $total workloads to $outdir")
end

main(ARGS)
