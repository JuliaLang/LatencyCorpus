# Write Plots' own example gallery (`Plots._examples`, from which its documentation gallery
# is built) as one workload, for the GR backend:
#
#     julia --project=envs/plots runner/plots_gallery.jl <out.jl>
using Plots

function main(out)
    open(out, "w") do io
        println(io, "# env: plots")
        println(io, "# kind: unknown")
        println(io, "# source: Plots.jl src/examples.jl (Plots._examples), GR backend")
        println(io, "\n# %% load\nusing Plots")
        for (i, ex) in enumerate(Plots._examples)
            ex.external && continue
            i in Plots._backend_skips[:gr] && continue
            println(io, "\n# %% ", i, " ", ex.header)
            ex.imports === nothing || println(io, ex.imports)
            body = Base.remove_linenums!(deepcopy(ex.exprs))
            stmts = Meta.isexpr(body, :block) ? body.args : [body]
            for s in stmts
                println(io, s)
            end
        end
    end
end
main(ARGS[1])
