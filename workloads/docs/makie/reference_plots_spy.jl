# env: makie
# kind: interactive
# source: reference/plots/spy.md

# %% prelude
using CairoMakie

# %% 1
using SparseArrays

N = 10 # dimension of the sparse matrix
p = 0.1 # independent probability that an entry is zero

A = sprand(N, N, p)
f, ax, plt = spy(A, framecolor = :lightgrey, axis=(;
    aspect=1,
    title = "Visualization of a random sparse matrix")
)

hidedecorations!(ax) # remove axis labeling

f

# %% 2
using SparseArrays

S = spzeros(4, 4)
S[:, 1] .= 2.0
S[1, 2:4] .= 1.0
#=
Prints as:
4×4 SparseMatrixCSC{Float64, Int64} with 7 stored entries:
 2.0  1.0  1.0  1.0
 2.0   ⋅    ⋅    ⋅
 2.0   ⋅    ⋅    ⋅
 2.0   ⋅    ⋅    ⋅
=#

M = Matrix(S)

f = Figure(size = (600, 500))

a, p = heatmap(
    f[1, 1], M,
    colorrange = (1, 2), lowclip = :transparent,
    colormap = Categorical(:viridis), # just for Colorbar
    axis = (title = "heatmap",)
)
Colorbar(f[1:2, 3], p)
a, p = spy(f[1, 2], S, axis = (title = "spy",))

a, p = heatmap(
    f[2, 1], rotr90(M),
    colorrange = (1, 2), lowclip = :transparent,
    axis = (title = "rotated heatmap",)
)
a, p = spy(f[2, 2], rotr90(S), axis = (title = "rotated spy",))

f
