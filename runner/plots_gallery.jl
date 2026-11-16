# Write Plots' own example gallery (`Plots._examples`, from which its documentation gallery
# is built) as one workload, for the GR backend:
#
#     julia --project=envs/plots runner/plots_gallery.jl <out.jl>
using Plots

# Remove line numbers everywhere, including those that `Base.remove_linenums!` leaves: the one
# each macro call carries, and those in its arguments. They would print as comments naming
# the file of the installed package.
function strip_linenums!(@nospecialize ex)
    ex isa Expr || return ex
    if ex.head === :macrocall && length(ex.args) >= 2 && ex.args[2] isa LineNumberNode
        ex.args[2] = nothing
    end
    filter!(a -> !(a isa LineNumberNode), ex.args)
    foreach(strip_linenums!, ex.args)
    return ex
end

function main(out)
    open(out, "w") do io
        println(io, "# env: plots")
        println(io, "# kind: unknown")
        tag = "https://github.com/JuliaPlots/Plots.jl/blob/Plots-v$(pkgversion(Plots))"
        println(io, "# source: $tag/Plots/src/examples.jl (Plots._examples), GR backend")
        println(io, "# license: $tag/Plots/LICENSE.md")
        println(io, "\n# %% load\nusing Plots")
        for (i, ex) in enumerate(Plots._examples)
            ex.external && continue
            i in Plots._backend_skips[:gr] && continue
            println(io, "\n# %% ", i, " ", ex.header)
            ex.imports === nothing || println(io, strip_linenums!(deepcopy(ex.imports)))
            body = strip_linenums!(deepcopy(ex.exprs))
            stmts = Meta.isexpr(body, :block) ? body.args : [body]
            for s in stmts
                println(io, s)
            end
        end
    end
end
main(ARGS[1])
