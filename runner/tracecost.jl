# What compiling costs, by CodeInstance and by compile root, from a trace of a run with
# tiering off (see tracedata.jl).

# The cost of compiling one CodeInstance, in seconds: its inference and optimization, its
# emission to LLVM IR, and its share, by instruction count, of the time to turn the batch it
# was emitted in into object code (LLVM's optimizer and code generator, which is 0 when the
# object cache hits, and the rest: cache lookup, linking).
struct CiCost
    infer::Float64
    emit::Float64
    llvm::Float64
    obj::Float64
    instrs::Int
end
CiCost() = CiCost(0, 0, 0, 0, 0)
Base.:+(a::CiCost, b::CiCost) = CiCost(a.infer + b.infer, a.emit + b.emit, a.llvm + b.llvm,
                                       a.obj + b.obj, a.instrs + b.instrs)
total(c::CiCost; llvm=true) = c.infer + c.emit + (llvm ? c.llvm : 0.0) + c.obj

# Cost by CodeInstance id. CodeInstances that were inferred but never emitted (used only for
# inlining, or not compiled) have an inference cost only.
function ci_costs(t::Trace)
    cost = Dict{Int,CiCost}()
    for (c, (_, self, _, _)) in t.infer
        cost[c] = CiCost(self, 0, 0, 0, 0)
    end
    batch_instrs = Dict{Int,Int}()  # c => instructions in its batch
    instrs = Dict{Int,Int}()
    for (_, _, items) in t.emits
        n = sum(x[2] for x in items)
        for (c, k, ns) in items
            instrs[c] = k
            batch_instrs[c] = n
            cost[c] = get(cost, c, CiCost()) + CiCost(0, ns / 1e9, 0, 0, k)
        end
    end
    for (_, ns, llvm, hit, link, cs) in t.objs
        n = sum(c -> get(instrs, c, 0), cs; init=0)
        for c in cs
            share = n == 0 ? 1 / length(cs) : get(instrs, c, 0) / n
            cost[c] = get(cost, c, CiCost()) +
                CiCost(0, 0, share * llvm / 1e9, share * (ns - llvm + link) / 1e9, 0)
        end
    end
    return cost
end

# Cost by signature (summed over its CodeInstances, so a specialization compiled twice, as
# after an invalidation, costs twice), and how many CodeInstances that was.
function sig_costs(t::Trace)
    out = Dict{String,Tuple{CiCost,Int}}()
    for (c, k) in ci_costs(t)
        haskey(t.cis, c) || continue
        s = cisig(t, c)
        old, n = get(out, s, (CiCost(), 0))
        out[s] = (old + k, n + 1)
    end
    return out
end

# Compile roots with the wall time each spent outside the roots nested in it, and the cell
# each started in.
function root_times(t::Trace)
    roots = sort(t.roots)
    excl = [r[2] - r[1] for r in roots]
    # a stack of open roots: subtract each root from its innermost enclosing root
    stack = Int[]
    for (i, r) in enumerate(roots)
        while !isempty(stack) && roots[stack[end]][2] <= r[1]
            pop!(stack)
        end
        isempty(stack) || (excl[stack[end]] -= r[2] - r[1])
        push!(stack, i)
    end
    return roots, excl ./ 1e9
end

# Top-level compile time in each cell: roots not nested in another root, by the cell their
# start falls in.
function cell_compile(t::Trace)
    roots, _ = root_times(t)
    out = Dict{String,Float64}()
    cs = cells(t)
    last = 0
    for r in roots
        r[1] < last && continue  # nested
        last = r[2]
        for (name, t0, t1, _, _) in cs
            if t0 <= r[1] < t1
                out[name] = get(out, name, 0.0) + (r[2] - r[1]) / 1e9
                break
            end
        end
    end
    return out
end

# As ci_costs, but with the inference of CodeInstances that were never emitted (inferred
# for inlining, or for calls that stay dynamic) charged to the nearest emitted CodeInstance
# whose inference they ran within: that is the compile they are part of.
function attributed_costs(t::Trace)
    cost = ci_costs(t)
    emitted = Set{Int}()
    for (_, _, items) in t.emits, (c, _, _) in items
        push!(emitted, c)
    end
    # inference intervals, nested as inference recurses
    iv = [(tend - round(Int, total * 1e9), tend, c) for (c, (tend, _, total, _)) in t.infer]
    sort!(iv, by = x -> (x[1], -x[2]))
    stack = Tuple{Int,Int}[]  # (end, c)
    for (t0, t1, c) in iv
        while !isempty(stack) && stack[end][1] < t1
            pop!(stack)
        end
        if !(c in emitted)
            i = findlast(x -> x[2] in emitted, stack)
            if i !== nothing
                p = stack[i][2]
                k = cost[c]
                cost[p] = cost[p] + CiCost(k.infer, 0, 0, 0, 0)
                cost[c] = CiCost(0, k.emit, k.llvm, k.obj, k.instrs)
            end
        end
        push!(stack, (t1, c))
    end
    return cost
end

# The tree of inferences: each CodeInstance's parent is the innermost inference whose time
# it was inferred within, which is the one that recursed into it. Compiling something from
# scratch infers its subtree, less whatever earlier compiles inferred already.
function infer_tree(t::Trace)
    iv = [(tend - round(Int, total * 1e9), tend, c) for (c, (tend, _, total, _)) in t.infer]
    sort!(iv, by = x -> (x[1], -x[2]))
    kids = Dict{Int,Vector{Int}}()
    stack = Tuple{Int,Int}[]  # (end, c)
    for (t0, t1, c) in iv
        while !isempty(stack) && stack[end][1] < t1
            pop!(stack)
        end
        isempty(stack) || push!(get!(kids, stack[end][2], Int[]), c)
        push!(stack, (t1, c))
    end
    return kids
end

# What inferring each CodeInstance used and inferred, nested or found cached (`d` records),
# with what was inferred nested within it (`infer_tree`): charging a CodeInstance with
# what is not inferred yet of what it used does not depend on the order things were
# inferred in when the trace was recorded. Used MethodInstances stand for the first of
# their CodeInstances that was inferred.
function infer_deps(t::Trace)
    kids = infer_tree(t)
    first_ci = Dict{Int,Tuple{Int,Int}}()  # s => (time inferred, c)
    for (c, (tend, _, _, _)) in t.infer
        s = get(t.cis, c, nothing)
        s === nothing && continue
        (!haskey(first_ci, s) || tend < first_ci[s][1]) && (first_ci[s] = (tend, c))
    end
    for (c, cs) in t.deps
        k = get!(kids, c, Int[])
        append!(k, cs)
        for s in get(t.depmis, c, Int[])
            x = get(first_ci, s, nothing)
            x === nothing || push!(k, x[2])
        end
        unique!(k)
        filter!(!=(c), k)
    end
    return kids
end
