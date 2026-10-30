# env: makie
# kind: unknown
# source: reference/plots/triplot.md

# %% prelude
using CairoMakie

# %% 1
using DelaunayTriangulation

using Random
Random.seed!(1234)

points = randn(Point2f, 50)
f, ax, tr = triplot(points, show_points = true, triangle_color = :lightblue)

tri = triangulate(points)
ax, tr = triplot(f[1, 2], tri, show_points = true)
f

# %% 2
using DelaunayTriangulation

n = 20
angles = range(0, 2pi, length = n+1)[1:end-1]
x = [cos.(angles); 2 .* cos.(angles .+ pi/n)]
y = [sin.(angles); 2 .* sin.(angles .+ pi/n)]
inner = [n:-1:1; n] # clockwise inner
outer = [(n+1):(2n); n+1] # counter-clockwise outer
boundary_nodes = [[outer], [inner]]
points = [x'; y']
tri = triangulate(points; boundary_nodes = boundary_nodes)

f, ax, tr = triplot(tri; show_ghost_edges = true, show_points = true)
f

# %% 3
using DelaunayTriangulation

using Random
Random.seed!(1234)

outer = [
    (0.0,0.0),(2.0,1.0),(4.0,0.0),
    (6.0,2.0),(2.0,3.0),(3.0,4.0),
    (6.0,6.0),(0.0,6.0),(0.0,0.0)
]
inner = [
    (1.0,5.0),(2.0,4.0),(1.01,1.01),
    (1.0,1.0),(0.99,1.01),(1.0,5.0)
]
boundary_points = [[outer], [inner]]
boundary_nodes, points = convert_boundary_points_to_indices(boundary_points)
tri = triangulate(points; boundary_nodes = boundary_nodes)
refine!(tri; max_area=1e-3*get_area(tri))

f, ax, tr = triplot(tri, show_constrained_edges = true, constrained_edge_linewidth = 4, show_convex_hull = true)
f
