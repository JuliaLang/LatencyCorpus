# env: base
# kind: interactive
# about: Log triage with only Base: parse timestamps, pull fields out with a regex, count by hour and level.

# %% load
using Dates, Printf, Random

# %% make a log
rng = Xoshiro(11)
levels = ("INFO", "INFO", "INFO", "WARN", "ERROR")
paths = ("/api/users", "/api/orders", "/health", "/api/items", "/login")
lines = String[]
t = DateTime(2026, 3, 1)
for i in 1:20_000
    global t += Millisecond(rand(rng, 1:9000))
    push!(lines, string(Dates.format(t, "yyyy-mm-ddTHH:MM:SS.sss"), " ", rand(rng, levels), " ",
        rand(rng, paths), " status=", rand(rng, (200, 200, 200, 404, 500)), " ms=", rand(rng, 1:900)))
end
length(lines)

# %% parse
re = r"^(\S+) (\w+) (\S+) status=(\d+) ms=(\d+)$"
entries = map(lines) do l
    m = match(re, l)
    (time = DateTime(m[1]), level = m[2], path = m[3], status = parse(Int, m[4]), ms = parse(Int, m[5]))
end
first(entries, 3)

# %% count by hour
byhour = Dict{Int,Int}()
for e in entries
    byhour[hour(e.time)] = get(byhour, hour(e.time), 0) + 1
end
sort!(collect(byhour))

# %% errors by path
errs = filter(e -> e.level == "ERROR" || e.status >= 500, entries)
counts = Dict{String,Int}()
for e in errs
    counts[e.path] = get(counts, e.path, 0) + 1
end
sort(collect(counts); by = last, rev = true)

# %% slowest requests
slow = sort(entries; by = e -> e.ms, rev = true)[1:5]
for e in slow
    @printf("%s  %-12s %4d ms  %d\n", Dates.format(e.time, "HH:MM:SS"), e.path, e.ms, e.status)
end
