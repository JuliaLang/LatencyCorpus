# env: base
# kind: interactive
# mode: script
# about: Text processing script: count words in a generated corpus, report the most common.

# %% setup
using Random
rng = Xoshiro(1)
vocab = [String(rand(rng, 'a':'z', rand(rng, 2:9))) for _ in 1:2000]
text = join((vocab[min(length(vocab), ceil(Int, 1 / rand(rng)))] for _ in 1:200_000), ' ');

# %% count
counts = Dict{String,Int}()
for w in split(text)
    counts[w] = get(counts, w, 0) + 1
end
length(counts)

# %% top words
top = sort!(collect(counts); by=last, rev=true)[1:10]

# %% report
for (w, n) in top
    println(rpad(w, 12), lpad(n, 8))
end
