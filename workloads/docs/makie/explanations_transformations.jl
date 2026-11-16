# env: makie
# kind: interactive
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/transformations.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
using Makie

double(x) = 2 * x
t = Transformation(double, translation = Vec3f(1,2,3))
scene = Scene(transformation = t);
child = Scene(scene);
display(scene.transformation)
child.transformation

# %% 2
scale!(child, 1, 2, 2)
translate!(child, 0, 0, -3)
child.transformation

# %% 3
# Reference plot (black empty circles)
r = Rect2f(1, 0, 1, 2)
f,a,p = scatter(r, color = :white, strokecolor = :black, strokewidth = 2, markersize = 20)

# Option 1:
# Pass multiple functions as a tuple, with each acting in a different dimension
t1 = Transformation((x -> 2x, y -> 0.5y))
scatter!(r, color = :red, markersize = 20, marker = '+', transformation = t1)

# Option 2:
# Wrap a function accepting points in `Makie.PointTrans`
t2 = Transformation(Makie.PointTrans{2}(xy -> Point(xy[2], xy[1])))
scatter!(r, color = :blue, markersize = 20, marker = 'x', transformation = t2)

# Option 3:
# Add a `apply_transform` method for a specific transform function.
# Boundingboxes will likely require a 3D version of the transform function
mytransform(p::VecTypes{2}) = Point(p[1] + 0.5, 0.5 * p[2])
mytransform(p::VecTypes{3}) = Point(p[1] + 0.5, 0.5 * p[2], p[3])
Makie.apply_transform(f::typeof(mytransform), p::VecTypes) = f(p)
t3 = Transformation(mytransform)
scatter!(r, color = :green, markersize = 20, marker = :rect, transformation = t3)

f
