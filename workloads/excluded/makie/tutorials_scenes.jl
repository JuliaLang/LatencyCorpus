# env: makie
# kind: unknown
# source: tutorials/scenes.md

# %% prelude
using CairoMakie

# %% 1
# pruned: failed without tiering
# %% 2
# pruned: failed without tiering
# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
scene = Scene(backgroundcolor=:gray)
lines!(scene, Rect2f(-1, -1, 2, 2), linewidth=5, color=:black)
scene

# %% 8
cam = Makie.camera(scene) # this is how to access the scenes camera

# %% 9
cam.projection[] = Makie.orthographicprojection(-3f0, 5f0, -3f0, 5f0, -100f0, 100f0)
scene

# %% 10
w, h = size(scene)
nearplane = 0.1f0
farplane = 100f0
aspect = Float32(w / h)
cam.projection[] = Makie.perspectiveprojection(45f0, aspect, nearplane, farplane)
# Now, we also need to change the view matrix
# to "put" the camera into some place.
eyeposition = Vec3f(10)
lookat = Vec3f(0)
upvector = Vec3f(0, 0, 1)
cam.view[] = Makie.lookat(eyeposition, lookat, upvector)
scene

# %% 11
figure, axis, plot_object = scatter(1:4)
relative_projection = Makie.camrelative(axis.scene);
scatter!(relative_projection, [Point2f(0.5)], color=:red)
# offset & text are in pixelspace
text!(relative_projection, "Hi", position=Point2f(0.5), offset=Vec2f(5))
lines!(relative_projection, Rect(0, 0, 1, 1), color=:blue, linewidth=3)
figure

# %% 12
scene = Scene()
cam3d!(scene)
sphere_plot = mesh!(scene, Sphere(Point3f(0), 0.5), color=:red)
scale!(scene, 0.5, 0.5, 0.5)
rotate!(scene, Vec3f(1, 0, 0), 0.5) # 0.5 rad around the y axis
scene

# %% 13
translate!(sphere_plot, Vec3f(0, 0, 1))
scene

# %% 14
parent = Scene()
cam3d!(parent; clipping_mode = :static)

# One can set the camera lookat and eyeposition, by getting the camera controls and using `update_cam!`
camc = cameracontrols(parent)
update_cam!(parent, camc, Vec3f(0, 8, 0), Vec3f(4.0, 0, 0))
# One may need to adjust the
# near and far clip plane when adjusting the camera manually
camc.far[] = 100f0
s1 = Scene(parent, camera=parent.camera)
mesh!(s1, Rect3f(Vec3f(0, -0.1, -0.1), Vec3f(5, 0.2, 0.2)))
s2 = Scene(s1, camera=parent.camera)
mesh!(s2, Rect3f(Vec3f(0, -0.1, -0.1), Vec3f(5, 0.2, 0.2)), color=:red)
translate!(s2, 5, 0, 0)
s3 = Scene(s2, camera=parent.camera)
mesh!(s3, Rect3f(Vec3f(-0.2), Vec3f(0.4)), color=:blue)
translate!(s3, 5, 0, 0)
parent

# %% 15
# Now, rotate the "joints"
rotate!(s2, Vec3f(0, 1, 0), 0.5)
rotate!(s3, Vec3f(1, 0, 0), 0.5)
parent
