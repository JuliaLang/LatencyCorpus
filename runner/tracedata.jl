# Reading compile traces (`JULIA_COMPILE_TRACE`; the record format is described at the top
# of src/ctrace.c in the tiered branch) into tables keyed by signature, so that runs of the
# same workload in different modes can be joined.

struct MethodInfo
    flags::String
    nstmts::Int
    nloops::Int
    ncalls::Int
    nargs::Int
    mod::String
    name::String
    file::String
end

# A function instrumented with block counters (`b`, `f`, `k` records).
struct Fn
    ci::Int
    frames::Vector{Tuple{Int,String,Int}}  # parent, def, first block
    backedge::Vector{Int}                  # by block: the frame whose back-edge ends it, or -1
    stmts::Vector{Vector{Tuple{Int,Int}}}  # by block: (frame, statements)
end

struct Mark
    t::Int
    label::String
end

mutable struct Trace
    path::String
    mode::String
    mis::Dict{Int,Tuple{Int,String}}           # s => (m, signature)
    methods::Dict{Int,MethodInfo}
    cis::Dict{Int,Int}                         # c => s
    infer::Dict{Int,Tuple{Int,Float64,Float64,Float64}}  # c => (t, self, total, saved)
    emits::Vector{Tuple{Int,Int,Vector{Tuple{Int,Int,Int}}}}  # (t, ns, [(c, instrs, ns)])
    objs::Vector{Tuple{Int,Int,Int,Bool,Int,Vector{Int}}}     # (t, ns, llvm, hit, link, cs)
    roots::Vector{Tuple{Int,Int,Int,String}}   # (t0, t1, s, why)
    marks::Vector{Mark}
    calls::Dict{Int,Vector{Int}}               # c => directly called cs
    interp::Dict{Int,NTuple{5,Int}}            # s => (calls, stmts, backedges, incl, excl)
    fns::Dict{Int,Fn}                          # q => function
    counts::Dict{Int,Vector{Tuple{Int,Vector{Int}}}}  # q => [(marks seen before, counts)]
end

Trace(path, mode) = Trace(path, mode, Dict(), Dict(), Dict(), Dict(), [], [], [], [], Dict(),
                          Dict(), Dict(), Dict())

const P = s -> parse(Int, s)
splitints(s) = isempty(s) ? Int[] : P.(split(s, ','))

function read_trace(path::String, mode::String="")
    t = Trace(path, mode)
    frames = Dict{Int,Vector{Tuple{Int,String,Int}}}()
    blocks = Dict{Int,Vector{Tuple{Int,Int,Vector{Tuple{Int,Int}}}}}()
    fnci = Dict{Int,Int}()
    for line in eachline(path)
        f = split(line, '\t')
        k = f[1]
        if k == "s"
            t.mis[P(f[2])] = (P(f[3]), f[4])
        elseif k == "m"
            file = join(f[10:end], '\t')
            t.methods[P(f[2])] = MethodInfo(f[3], P(f[4]), P(f[5]), P(f[6]), P(f[7]), f[8], f[9], file)
        elseif k == "c"
            t.cis[P(f[2])] = P(f[3])
        elseif k == "i"
            t.infer[P(f[2])] = (P(f[3]), parse(Float64, f[4]), parse(Float64, f[5]), parse(Float64, f[6]))
        elseif k == "e"
            items = [Tuple(P.(split(x, ':'))) for x in split(f[4], ',')]
            push!(t.emits, (P(f[2]), P(f[3]), items))
        elseif k == "o"
            push!(t.objs, (P(f[2]), P(f[3]), P(f[4]), f[5] == "1", P(f[6]), splitints(f[7])))
        elseif k == "r"
            push!(t.roots, (P(f[2]), P(f[3]), P(f[4]), f[5]))
        elseif k == "x"
            push!(t.marks, Mark(P(f[2]), join(f[3:end], '\t')))
        elseif k == "g"
            t.calls[P(f[2])] = splitints(f[3])
        elseif k == "p"
            t.interp[P(f[2])] = (P(f[3]), P(f[4]), P(f[5]), P(f[6]), P(f[7]))
        elseif k == "b"
            q = P(f[2])
            fnci[q] = P(f[3])
            frames[q] = Tuple{Int,String,Int}[]
            blocks[q] = Tuple{Int,Int,Vector{Tuple{Int,Int}}}[]
        elseif k == "f"
            push!(frames[P(f[2])], (P(f[4]), String(f[5]), P(f[6])))
        elseif k == "k"
            st = isempty(f[5]) ? Tuple{Int,Int}[] : [Tuple(P.(split(x, ':'))) for x in split(f[5], ',')]
            push!(blocks[P(f[2])], (P(f[3]), P(f[4]), st))
        elseif k == "n"
            push!(get!(t.counts, P(f[2]), Tuple{Int,Vector{Int}}[]), (length(t.marks), splitints(f[4])))
        end
    end
    for (q, fr) in frames
        bl = sort(blocks[q])
        t.fns[q] = Fn(fnci[q], fr, [b[2] for b in bl], [b[3] for b in bl])
    end
    return t
end

sig(t::Trace, s::Int) = t.mis[s][2]
cisig(t::Trace, c::Int) = sig(t, t.cis[c])
method_of(t::Trace, s::Int) = get(t.methods, t.mis[s][1], nothing)

# The signature a frame's definition names: a MethodInstance's, or for a Method, its name.
function defkey(t::Trace, def::AbstractString)
    def == "-" && return nothing
    id = parse(Int, def[2:end])
    def[1] == 's' && return sig(t, id)
    m = get(t.methods, id, nothing)
    return m === nothing ? nothing : "method $(m.mod).$(m.name) $(m.file)"
end

# Cells: (name, start, end) from the `cell <name>` and `end <name>` marks.
function cells(t::Trace)
    out = Tuple{String,Int,Int,Int,Int}[]  # name, t0, t1, mark index of start, of end
    open = Dict{String,Tuple{Int,Int}}()
    for (i, m) in enumerate(t.marks)
        if startswith(m.label, "cell ")
            open[m.label[6:end]] = (m.t, i)
        elseif startswith(m.label, "end ")
            name = m.label[5:end]
            haskey(open, name) || continue
            t0, i0 = pop!(open, name)
            push!(out, (name, t0, m.t, i0, i))
        end
    end
    return out
end

# The counts of function q once `k` marks had been written (the start of a cell is mark
# index i0: counts written before it are those recorded with `marks seen` < i0).
function counts_at(t::Trace, q::Int, k::Int)
    h = get(t.counts, q, nothing)
    h === nothing && return nothing
    c = nothing
    for (seen, v) in h
        seen < k || break
        c = v
    end
    return c
end

# Work by signature that ran in function q between two count vectors: per frame
# definition, calls (entries into the frame), statements and back-edges, split by whether
# the frame is the function itself (`own`) or inlined into it.
struct Work
    calls::Float64
    stmts::Float64
    iters::Float64
end
Base.:+(a::Work, b::Work) = Work(a.calls + b.calls, a.stmts + b.stmts, a.iters + b.iters)
Base.zero(::Type{Work}) = Work(0, 0, 0)

function fn_work!(acc::Dict{Tuple{String,String},Work}, t::Trace, q::Int, c::Vector{Int})
    fn = t.fns[q]
    host = cisig(t, fn.ci)
    nb = min(length(c), length(fn.stmts))
    nf = length(fn.frames)
    calls = zeros(nf); stmts = zeros(nf); iters = zeros(nf)
    for b in 1:nb
        n = c[b]
        n == 0 && continue
        for (fr, k) in fn.stmts[b]
            stmts[fr + 1] += n * k
        end
        be = fn.backedge[b]
        be >= 0 && (iters[be + 1] += n)
    end
    for (i, (parent, def, block)) in enumerate(fn.frames)
        calls[i] = block + 1 <= length(c) ? c[block + 1] : 0
    end
    calls[1] = isempty(c) ? 0 : c[1]
    for (i, (parent, def, block)) in enumerate(fn.frames)
        key = i == 1 ? host : defkey(t, def)
        key === nothing && continue
        ctx = i == 1 ? "" : host
        w = Work(calls[i], stmts[i], iters[i])
        acc[(key, ctx)] = get(acc, (key, ctx), zero(Work)) + w
    end
    return acc
end

# Work by (signature, host) in each cell, from a counts trace: host "" is the
# specialization's own code, otherwise the signature of the function it was inlined into.
function cell_work(t::Trace)
    out = Dict{String,Dict{Tuple{String,String},Work}}()
    for (name, _, _, i0, i1) in cells(t)
        acc = Dict{Tuple{String,String},Work}()
        for q in keys(t.fns)
            c1 = counts_at(t, q, i1)
            c1 === nothing && continue
            c0 = counts_at(t, q, i0)
            d = c0 === nothing ? c1 : c1 .- c0[1:length(c1)]
            any(!iszero, d) && fn_work!(acc, t, q, d)
        end
        out[name] = acc
    end
    return out
end
