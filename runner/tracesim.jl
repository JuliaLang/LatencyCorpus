# Replaying tiering heuristics against compile traces (tracedata.jl, tracecost.jl).
#
# What tiering does is decided at the boundary between interpreted and compiled code, so
# the replay works in the interpreter's terms. The rtrace recording of a workload (run.jl)
# interprets nearly everything and says, for each cell: which specializations ran
# interpreted, called from which interpreted callers (or from compiled code), and what that
# cost beyond the native code the calls ran; then, at the end, what compiling each of them
# would have cost, which of them that compile drags in (its static callees), and what it
# inlines. A heuristic is a rule that decides, as work arrives, when each specialization
# compiles. Compiling one takes its calls, and the calls it inlines or makes statically,
# out of the interpreter; dynamic calls from it still go to the interpreter. A cell's time
# is then its time with tiering off, less the compiling that run did, plus the compiling
# and the interpreting the rule causes.

using Statistics

include("tracedata.jl")
include("tracecost.jl")

const ROOT = normpath(joinpath(@__DIR__, ".."))

# A call edge's interpreted totals within one cell.
struct Edge
    caller::String   # "" for calls from compiled code or the top level
    callee::String
    calls::Float64
    stmts::Float64
    penalty::Float64 # seconds spent interpreting, beyond the native code the frames called
end

struct Workload
    name::String
    kind::String
    cells::Vector{String}
    edges::Dict{String,Vector{Edge}}      # cell => what ran interpreted
    rank::Dict{String,Int}                # sig => order of first interpreted call
    loops::Dict{String,Float64}           # sig => statements per call, in its busiest cell
    cost::Dict{String,CiCost}             # sig => what compiling its own code costs, but for
                                          # inference: the rest of the compile pipeline
    ci::Dict{String,Int}                  # sig => its CodeInstance in the recording
    self::Dict{Int,Float64}               # CodeInstance => its own inference time
    kids::Dict{Int,Vector{Int}}           # CodeInstance => the inferences it recursed into
    callees::Dict{String,Vector{String}}  # sig => sigs its code calls directly
    inlined::Dict{String,Set{String}}     # sig => sigs its code inlines
    forced::Dict{String,Vector{String}}   # cell => compiles every heuristic does
    features::Dict{String,MethodInfo}
    off::Dict{Symbol,Dict{String,Tuple{Float64,Float64}}}  # :cold, :warm => cell => (wall, compile)
    measured::Dict{String,Dict{String,Float64}}  # mode => cell => wall less loading
end

function header_lines(name)
    for dir in ("docs", "gallery", "sessions", "scripts", "throughput", "adversarial", "")
        file = joinpath(ROOT, "workloads", dir, name * ".jl")
        isfile(file) && return filter(startswith("# "), readlines(file))
    end
    return String[]
end

function measured_cells(dir, name)
    out = Dict{String,Dict{String,Float64}}()
    for l in eachline(joinpath(dir, "results.tsv"))
        f = split(l, '\t')
        (f[3] == name && f[4] != "process") || continue
        load = length(f) >= 11 ? something(tryparse(Float64, f[11]), 0.0) : 0.0
        get!(out, f[1], Dict{String,Float64}())[f[4]] = parse(Float64, f[5]) - load
    end
    return out
end

function off_cells(t::Trace, measured)
    cc = cell_compile(t)
    Dict(name => (get(measured, name, (t1 - t0) / 1e9), get(cc, name, 0.0)) for (name, t0, t1, _, _) in cells(t))
end

# Compiles that are the heuristic's to decide; tiering does the others whatever the budgets
# say.
const DECIDED = ("interpreted", "budget", "continuation")

# `rdir` holds the rtrace recording; `dir` the others (trace, wtrace) and the measured runs.
function load_workload(dir::String, name::String; rdir::String=dir)
    file(d, mode) = (p = joinpath(d, "trace", replace(name, '/' => '-') * "-$mode-1.trace"); isfile(p) ? p : nothing)
    pc, pw, pr = file(dir, "trace"), file(dir, "wtrace"), file(rdir, "rtrace")
    any(isnothing, (pc, pw, pr)) && return nothing
    cold, warm, r = read_trace(pc, "trace"), read_trace(pw, "wtrace"), read_trace(pr, "rtrace")
    hdr = header_lines(name)
    i = findfirst(startswith("# kind:"), hdr)
    kind = i === nothing ? "interactive" : String(strip(hdr[i][8:end]))

    # what ran interpreted, by cell
    _, byedge = cell_interp(r)
    edges = Dict{String,Vector{Edge}}()
    loops = Dict{String,Float64}()
    for (cell, d) in byedge
        es = Edge[]
        per = Dict{String,Tuple{Float64,Float64}}()
        for ((p, c), (calls, stmts, excl, native, compiled)) in d
            # what interpreting costs: the frames' time less what they spent in compiled
            # code, which runs with tiering off too, or compiling it, which is a root
            push!(es, Edge(p, c, calls, stmts, max(excl - compiled, 0) / 1e9))
            a, b = get(per, c, (0.0, 0.0)); per[c] = (a + calls, b + stmts)
        end
        edges[cell] = es
        for (c, (calls, stmts)) in per
            loops[c] = max(get(loops, c, 0.0), stmts / calls)
        end
    end
    rank = Dict{String,Int}()
    for s in sort!(collect(keys(r.interp)))
        get!(rank, sig(r, s), s)
    end

    # what compiling costs, and what a compile takes with it
    cost = Dict{String,CiCost}(); ci = Dict{String,Int}(); best = Dict{String,Float64}()
    for (c, k) in ci_costs(r)
        haskey(r.cis, c) || continue
        s = cisig(r, c)
        total(k) > get(best, s, -1.0) || continue
        best[s] = total(k)
        cost[s] = CiCost(0, k.emit, k.llvm, k.obj, k.instrs)
        ci[s] = c
    end
    self = Dict(c => v[2] for (c, v) in r.infer)
    kids = infer_deps(r)
    callees = Dict{String,Vector{String}}()
    for (c, cs) in r.calls
        haskey(r.cis, c) || continue
        callees[cisig(r, c)] = unique!([cisig(r, x) for x in cs if haskey(r.cis, x)])
    end
    inlined = Dict{String,Set{String}}()
    for fn in values(r.fns)
        host = get!(inlined, cisig(r, fn.ci), Set{String}())
        for (i, (_, def, _)) in enumerate(fn.frames)
            i == 1 && continue
            k = defkey(r, def)
            k === nothing || push!(host, k)
        end
    end
    forced = Dict{String,Vector{String}}()
    for (cname, t0, t1, _, _) in cells(r)
        forced[cname] = [sig(r, x[3]) for x in sort(r.roots) if t0 <= x[1] < t1 && !(x[4] in DECIDED)]
    end
    features = Dict{String,MethodInfo}()
    for (s, (m, k)) in r.mis
        mi = get(r.methods, m, nothing)
        mi === nothing || (features[k] = mi)
    end
    meas = measured_cells(dir, name)
    off = Dict(:cold => off_cells(cold, get(meas, "trace", Dict())),
               :warm => off_cells(warm, get(meas, "wtrace", Dict())))
    cellnames = [c[1] for c in cells(cold)]
    return Workload(name, kind, cellnames, edges, rank, loops, cost, ci, self, kids, callees,
                    inlined, forced, features, off, meas)
end

function load_all(dir::String; rdir::String=dir)
    names = String[]
    for l in eachline(joinpath(rdir, "results.tsv"))
        f = split(l, '\t')
        f[1] == "rtrace" && !(f[3] in names) && push!(names, f[3])
    end
    wls = Workload[]
    for n in names
        w = load_workload(dir, n; rdir)
        w === nothing || push!(wls, w)
    end
    return wls
end

# --- heuristics ----------------------------------------------------------------------------

# What a heuristic sees about a specialization when it decides: its method's features, and
# how much it has run interpreted so far.
struct Seen
    sig::String
    features::Union{MethodInfo,Nothing}
    work::Float64       # statements interpreted so far, plus one per call
    calls::Float64
end

# A heuristic: `budget(seen)` is how much more interpreted work (statements, plus one per
# call) a specialization may do before its next dispatch compiles it, Inf to keep
# interpreting, 0 to compile at once. `loop` is the per-call budget for loops: a call that
# runs longer compiles (as a continuation) after that much work.
struct Heuristic
    name::String
    budget::Function
    loop::Float64
end
Heuristic(f::Function, name::String, loop) = Heuristic(name, f, Float64(loop))

needs_compiler(f::MethodInfo; inbounds=false) = any(in(f.flags), inbounds ? "CVFGO" : "IBPCVFGO")

# Tiering as it is: compile what the interpreter would run differently, and anything that
# has done JULIA_TIER_WORK statements.
function current(; work=20000, loop=20000, inbounds=false, name="current")
    Heuristic(name, loop) do s
        f = s.features
        f !== nothing && needs_compiler(f; inbounds) && return 0.0
        return max(work - s.work, 0.0)
    end
end

const never = Heuristic("never", s -> Inf, Inf)
const always = Heuristic("always", s -> 0.0, Inf)

# --- replay ---------------------------------------------------------------------------------

struct CellResult
    wall::Float64       # predicted
    compile::Float64
    interp::Float64
    native::Float64     # the cell's time with tiering off, less its compiling
end

struct SimResult
    cells::Dict{String,CellResult}
    compiled::Vector{Tuple{String,String}}  # (cell, root), in order
    cost::Dict{String,Float64}          # root => what compiling it cost
    after::Dict{String,Float64}         # sig => calls compiled code took out of the interpreter
end

# Infer the subtree of CodeInstance c that is not inferred yet.
function infer!(inferred::Set{Int}, w::Workload, c::Int)
    t = 0.0
    stack = [c]
    while !isempty(stack)
        x = pop!(stack)
        x in inferred && continue
        push!(inferred, x)
        t += get(w.self, x, 0.0)
        append!(stack, get(w.kids, x, Int[]))
    end
    return t
end

# Compile s with what it calls directly, charging what is not compiled yet: the inference
# of each, and of what each inlines, and the rest of the pipeline for each.
function compile!(compiled::Set{String}, inferred::Set{Int}, w::Workload, costs::Function, s::String)
    c = 0.0
    stack = [s]
    while !isempty(stack)
        x = pop!(stack)
        x in compiled && continue
        push!(compiled, x)
        k = get(w.cost, x, nothing)
        k === nothing || (c += costs(k))
        i = get(w.ci, x, nothing)
        i === nothing || (c += infer!(inferred, w, i))
        for y in get(w.inlined, x, ())
            j = get(w.ci, y, nothing)
            j === nothing || (c += infer!(inferred, w, j))
        end
        append!(stack, get(w.callees, x, String[]))
    end
    return c
end

# Compile a loop continuation of s: what s calls statically compiles for good, while s's
# own code compiles into the continuation only, so compiling s itself later infers and
# emits it again.
function continuation!(compiled::Set{String}, inferred::Set{Int}, w::Workload, costs::Function, s::String)
    c = 0.0
    for y in get(w.callees, s, String[])
        c += compile!(compiled, inferred, w, costs, y)
    end
    k = get(w.cost, s, nothing)
    k === nothing || (c += costs(k))
    tmp = copy(inferred)
    for y in (s, get(w.inlined, s, ())...)
        j = get(w.ci, y, nothing)
        j === nothing || (c += infer!(tmp, w, j))
    end
    return c
end

const COSTS = Dict(:cold => k -> total(k), :warm => k -> total(k; llvm=false))

function simulate(w::Workload, h::Heuristic; cache::Symbol=:cold)
    costs = COSTS[cache]
    compiled = Set{String}(); inferred = Set{Int}()
    seen = Dict{String,Float64}(); calls_seen = Dict{String,Float64}()
    continued = Set{String}()
    roots = Tuple{String,String}[]; rootcost = Dict{String,Float64}(); after = Dict{String,Float64}()
    out = Dict{String,CellResult}()
    inl(p, c) = c in get(w.inlined, p, ())
    for cell in w.cells
        compile_t = 0.0; interp_t = 0.0
        for s in get(w.forced, cell, String[])
            s in compiled && continue
            c = compile!(compiled, inferred, w, costs, s)
            compile_t += c
            push!(roots, (cell, s)); rootcost[s] = c
        end
        into = Dict{String,Vector{Edge}}()
        for e in get(w.edges, cell, Edge[])
            push!(get!(into, e.callee, Edge[]), e)
        end
        order = sort!(collect(keys(into)), by = s -> (get(w.rank, s, typemax(Int)), s))
        f = Dict{String,Float64}()   # share of a sig's calls in this cell that ran interpreted
        for s in order
            calls = sum(e.calls for e in into[s])
            if s in compiled
                after[s] = get(after, s, 0.0) + calls
                f[s] = 0.0
                continue
            end
            # the calls that still reach the interpreter: those from interpreted callers, and
            # those from compiled ones that do not inline it (calling it statically would
            # have compiled it)
            icalls = 0.0; work = 0.0; pen = 0.0
            for e in into[s]
                share = if e.caller == ""
                    1.0
                else
                    fp = get(f, e.caller, e.caller in compiled ? 0.0 : 1.0)
                    fp + (1 - fp) * !inl(e.caller, s)
                end
                icalls += share * e.calls
                work += share * (e.stmts + e.calls)
                pen += share * e.penalty
            end
            if icalls <= 0
                f[s] = 0.0
                continue
            end
            # a call that does more than the loop budget runs its loop as a continuation
            # once that much is done, and later calls enter the cached continuation at
            # the loop: assume they interpret little but the call itself
            if s in continued
                pen *= icalls / work
                work = icalls
            elseif work / icalls > h.loop
                c = continuation!(compiled, inferred, w, costs, s)
                compile_t += c
                push!(roots, (cell, "continuation " * s)); rootcost["continuation " * s] = c
                push!(continued, s)
                eff = h.loop + icalls
                pen *= eff / work
                work = eff
            end
            seen_s = get(seen, s, 0.0)
            amount = h.budget(Seen(s, get(w.features, s, nothing), seen_s, get(calls_seen, s, 0.0)))
            # the budget is checked at dispatch: the call that spends it runs to its end
            # interpreted, and the next one compiles
            percall = work / icalls
            k = amount <= 0 ? 0.0 : ceil(amount / percall)
            if k >= icalls
                interp_t += pen
                seen[s] = seen_s + work
                calls_seen[s] = get(calls_seen, s, 0.0) + icalls
                f[s] = icalls / calls
            else
                frac = k / icalls
                amount = k * percall
                interp_t += frac * pen
                seen[s] = seen_s + amount
                c = compile!(compiled, inferred, w, costs, s)
                compile_t += c
                push!(roots, (cell, s)); rootcost[s] = c
                after[s] = get(after, s, 0.0) + (1 - frac) * icalls
                f[s] = frac * icalls / calls
            end
        end
        wall, offc = get(w.off[cache], cell, (0.0, 0.0))
        native = max(wall - offc, 0.0)
        out[cell] = CellResult(native + compile_t + interp_t, compile_t, interp_t, native)
    end
    return SimResult(out, roots, rootcost, after)
end

# --- the oracle ---------------------------------------------------------------------------

# What interpreting each specialization for the whole run costs, if everything else were
# interpreted too.
function penalties(w::Workload)
    pen = Dict{String,Float64}()
    for es in values(w.edges), e in es
        pen[e.callee] = get(pen, e.callee, 0.0) + e.penalty
    end
    return pen
end

# Compile, at its first call, each specialization whose interpreting costs more than
# compiling it on its own; interpret everything else. Knowing the future, it is a bound on
# what deciding one specialization at a time can do (a loose one: it ignores what compiling
# one drags in and takes out of the interpreter).
function oracle(w::Workload; cache::Symbol=:cold)
    pen = penalties(w)
    own(s) = compile!(Set{String}(), Set{Int}(), w, COSTS[cache], s)
    yes = Set(s for (s, p) in pen if p > own(s))
    Heuristic("oracle", s -> s.sig in yes ? 0.0 : Inf, Inf)
end

# --- reports --------------------------------------------------------------------------------

function geomean(xs)
    xs = filter(x -> x > 0, collect(xs))
    isempty(xs) ? NaN : exp(mean(log.(xs)))
end

# Predicted against measured cell times: (predicted, measured, label) for cells that take
# at least `min` seconds in either.
function validate(wls, h_for, cache, mode; min=0.05)
    pairs = Tuple{Float64,Float64,String}[]
    for w in wls
        meas = get(w.measured, mode, nothing)
        meas === nothing && continue
        res = simulate(w, h_for(w); cache)
        for (cell, c) in res.cells
            haskey(meas, cell) || continue
            a, b = c.wall, meas[cell]
            max(a, b) >= min || continue
            push!(pairs, (a, b, w.name * " | " * cell))
        end
    end
    return pairs
end
