# Remove the cells of documentation workloads that fail when run without tiering, using the
# results of a run.jl run:
#
#     julia runner/prune.jl <results dir> <workloads dir> [max fraction removed]
#
# Failing cells in extracted documentation are mostly code that needs something the corpus
# doesn't have: packages that aren't installed, GPU backends, helpers defined by a docs
# build. A pruned cell is replaced by a `# pruned` comment, so later runs keep the cell
# names. A workload that has lost more than the given fraction of its cells (default 0.3)
# is moved to workloads/excluded/<dir>/, since what remains is not the session it was.

const ROOT = dirname(@__DIR__)

function failures(results)
    failed = Dict{String,Set{String}}()
    for l in eachline(joinpath(results, "results.tsv"))
        f = split(l, '\t')
        f[4] != "process" && f[9] == "false" && push!(get!(failed, f[3], Set{String}()), f[4])
    end
    return failed
end

function prune(path, bad, maxfrac)
    lines = readlines(path)
    out = String[]
    total = pruned = 0
    skipping = false
    for l in lines
        if startswith(l, "# %%")
            name = strip(l[5:end])
            total += 1
            skipping = name in bad
            if skipping
                pruned += 1
                push!(out, l, "# pruned: failed without tiering")
                continue
            end
        elseif skipping
            continue
        end
        startswith(l, "# pruned") && (pruned += 1)
        push!(out, l)
    end
    write(path, join(out, '\n') * '\n')
    # count cells pruned earlier as well
    gone = count(l -> startswith(l, "# pruned"), out)
    return gone, total
end

function main(results, dir, maxfrac=0.3)
    failed = failures(results)
    for f in sort(readdir(dir; join=true))
        endswith(f, ".jl") || continue
        name = joinpath(basename(dir), splitext(basename(f))[1])
        haskey(failed, name) || continue
        gone, total = prune(f, failed[name], maxfrac)
        if gone > maxfrac * total
            dest = joinpath(ROOT, "workloads", "excluded", basename(dir))
            mkpath(dest)
            mv(f, joinpath(dest, basename(f)); force=true)
            println("excluded $name ($gone of $total cells failed)")
        else
            println("pruned $name ($gone of $total cells)")
        end
    end
end

main(ARGS[1], ARGS[2], length(ARGS) > 2 ? parse(Float64, ARGS[3]) : 0.3)
