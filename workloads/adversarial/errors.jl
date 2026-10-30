# env: base
# kind: latency
# about: Mistakes at the REPL: errors with stack traces are shown, and the session goes on.

# %% bounds
v = [1, 2, 3]
v[5]

# %% method error
f(x::Int) = x + 1
f("one")

# %% undefined
nonexistent_function(3)

# %% from deep code
g(n) = n == 0 ? error("bottom reached") : g(n - 1)
g(20)

# %% key error
Dict(:a => 1)[:b]

# %% recovers
f(41)
