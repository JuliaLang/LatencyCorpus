# env: plots
# kind: unknown
# source: pipeline.md

# %% prelude
using Plots

# %% 1
using Plots; gr()
Plots.reset_defaults()

# %% 2
n = 100
x, y = range(0, 1, length = n), randn(n, 3)

# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
Plots.reset_defaults() # hide
mutable struct MyVecWrapper
  v::Vector{Float64}
end
mv = MyVecWrapper(rand(10))

@recipe function f(mv::MyVecWrapper)
    markershape --> :circle
    markersize  --> 8
    mv.v
end

plot(
    plot(mv.v),
    plot(mv)
)

# %% 6
scatter(rand(100), group = rand(1:3, 100), marker = (10,0.3, [:s :o :x]))
