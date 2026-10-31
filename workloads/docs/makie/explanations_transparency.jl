# env: makie
# kind: interactive
# source: explanations/transparency.md

# %% prelude
using CairoMakie

# %% 1
using FileIO

# color
fig, ax, p = image(0..11, -1..11, rotr90(FileIO.load(Makie.assetpath("cow.png"))))
scatter!(ax, 1:10,fill(10, 10), markersize = 40, color = :red)
scatter!(ax, 1:10, fill(9, 10), markersize = 40, color = (:red, 0.5))
scatter!(ax, 1:10, fill(8, 10), markersize = 40, color = RGBf(0.8, 0.6, 0.1))
scatter!(ax, 1:10, fill(7, 10), markersize = 40, color = RGBAf(0.8, 0.6, 0.1, 0.5))

# colormap
scatter!(ax, 1:10, fill(5, 10), markersize = 40, color = 1:10, colormap = :viridis)
scatter!(ax, 1:10, fill(4, 10), markersize = 40, color = 1:10, colormap = (:viridis, 0.5),)
scatter!(ax, 1:10, fill(3, 10), markersize = 40, color = 1:10, colormap = [:red, :orange],)
scatter!(ax, 1:10, fill(2, 10), markersize = 40, color = 1:10, colormap = [(:red, 0.5), (:orange, 0.5)])
cm = [RGBf(x^2, 1 - x^2, 0.2) for x in range(0, 1, length=100)]
scatter!(ax, 1:10, fill(1, 10), markersize = 40, color = 1:10, colormap = cm)
cm = [RGBAf(x^2, 1 - x^2, 0.2, 0.5) for x in range(0, 1, length=100)]
scatter!(ax, 1:10, fill(0, 10), markersize = 40, color = 1:10, colormap = cm)
fig

# %% 2
scene = Scene(size = (400, 275))
campixel!(scene)
scatter!(
    scene, [100, 200, 300], [100, 100, 100],
    color = [RGBAf(1,0,0,0.5), RGBAf(0,0,1,0.5), RGBAf(1,0,0,0.5)],
    markersize=200
)
scatter!(scene, Point2f(150, 175), color = (:green, 0.5), markersize=200)
p = scatter!(scene, Point2f(250, 175), color = (:green, 0.5), markersize=200)
translate!(p, 0, 0, -1)
scene

# %% 3
fig = Figure()
ax = LScene(fig[1, 1], show_axis=false)
p1 = mesh!(ax, Rect2f(-1.5, -1, 3, 3), color = (:red, 0.5), shading = NoShading)
p2 = mesh!(ax, Rect2f(-1.5, -2, 3, 3), color = (:blue, 0.5), shading = NoShading)
rotate!(p1, Vec3f(0, 1, 0), 0.1)
rotate!(p2, Vec3f(0, 1, 0), -0.1)
fig
