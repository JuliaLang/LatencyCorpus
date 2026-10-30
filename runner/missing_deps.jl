# List packages that workloads load but their environment doesn't provide:
#     julia runner/missing_deps.jl workloads/docs/<dir>...
import TOML
const ROOT = dirname(@__DIR__)
stdlibs() = Set(readdir(Sys.STDLIB))

function loaded(path)
    names = Set{String}()
    for l in eachline(path)
        m = match(r"^\s*(?:using|import)\s+(.*)$", l)
        m === nothing && continue
        # `using M: a, b` loads only M; `using A, B; f()` loads A and B.
        mods = split(split(m[1], ';')[1], ':')[1]
        for part in split(mods, ',')
            name = strip(split(strip(part), r"[.\s]")[1])
            !isempty(name) && isuppercase(name[1]) && push!(names, name)
        end
    end
    return names
end

function main(dirs)
    std = stdlibs()
    for dir in dirs
        need = Dict{String,Vector{String}}()
        for f in readdir(dir; join=true)
            endswith(f, ".jl") || continue
            env = something(match(r"#\s*env:\s*(\S+)", read(f, String)), (; captures=["base"])).captures[1]
            deps = keys(get(TOML.parsefile(joinpath(ROOT, "envs", env, "Project.toml")), "deps", Dict()))
            for n in loaded(f)
                n in deps || n in std || push!(get!(need, n, String[]), basename(f))
            end
        end
        println("== $dir")
        for (n, fs) in sort!(collect(need); by=x -> -length(x[2]))
            println("  ", rpad(n, 36), length(fs))
        end
    end
end
main(ARGS)
