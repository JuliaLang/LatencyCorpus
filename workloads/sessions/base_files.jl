# env: base
# kind: interactive
# about: Everyday file work with only Base and stdlibs: write and read TOML, walk a directory, summarize file sizes.

# %% load
using TOML, Dates, Printf

# %% config
cfg = Dict("name" => "demo", "version" => "1.2.0",
    "server" => Dict("host" => "localhost", "port" => 8080, "debug" => true),
    "paths" => ["data", "logs", "out"])
open(io -> TOML.print(io, cfg), "config.toml", "w")
read("config.toml", String) |> print

# %% read it back
c = TOML.parsefile("config.toml")
c["server"]["port"] + 1

# %% make a tree
for d in c["paths"], i in 1:20
    mkpath(d)
    write(joinpath(d, "file$i.txt"), repeat("x", 100i))
end

# %% walk
sizes = Dict{String,Int}()
for (root, dirs, files) in walkdir(".")
    for f in files
        sizes[joinpath(root, f)] = filesize(joinpath(root, f))
    end
end
length(sizes), sum(values(sizes))

# %% report
for (p, s) in first(sort(collect(sizes); by = last, rev = true), 5)
    @printf("%-20s %6d bytes  %s\n", p, s, Dates.format(unix2datetime(mtime(p)), "yyyy-mm-dd"))
end
