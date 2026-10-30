# env: makie
# kind: unknown
# source: reference/blocks/polaraxis.md

# %% prelude
using CairoMakie

# %% 1

f = Figure()

ax = PolarAxis(f[1, 1], title = "Title")

f

# %% 2
f = Figure(size = (800, 400))

ax = PolarAxis(f[1, 1], title = "Theta as x")
lineobject = lines!(ax, 0..2pi, sin, color = :red)

ax = PolarAxis(f[1, 2], title = "R as x", theta_as_x = false)
scatobject = scatter!(range(0, 10, length=100), cos, color = :orange)

f

# %% 3
f = Figure(size = (600, 600))

ax = PolarAxis(f[1, 1], title = "Default")
lines!(ax, range(0, 8pi, length=300), range(0, 10, length=300))
ax = PolarAxis(f[1, 2], title = "thetalimits", thetalimits = (-pi/6, pi/6))
lines!(ax, range(0, 8pi, length=300), range(0, 10, length=300))

ax = PolarAxis(f[2, 1], title = "rlimits", rlimits = (5, 10))
lines!(ax, range(0, 8pi, length=300), range(0, 10, length=300))
ax = PolarAxis(f[2, 2], title = "both")
lines!(ax, range(0, 8pi, length=300), range(0, 10, length=300))
thetalims!(ax, -pi/6, pi/6)
rlims!(ax, 5, 10)

f

# %% 4
f = Figure()

ax = PolarAxis(f[1, 1], title = "Reoriented Axis", theta_0 = -pi/2, direction = -1)
lines!(ax, range(0, 8pi, length=300), range(0, 10, length=300))
thetalims!(ax, -pi/6, pi/6)
rlims!(ax, 5, 10)

f

# %% 5
f = Figure(size = (800, 500))

ax = PolarAxis(f[1, 1], title = "Surface")
rs = 0:10
phis = range(0, 2pi, 37)
cs = [r+cos(4phi) for phi in phis, r in rs]
p = surface!(ax, 0..2pi, 0..10, zeros(size(cs)), color = cs, shading = NoShading, colormap = :coolwarm)
ax.gridz = 100
tightlimits!(ax) # surface plots include padding by default
Colorbar(f[2, 1], p, vertical = false, flipaxis = false)

ax = PolarAxis(f[1, 2], title = "Voronoi")
rs = 1:10
phis = range(0, 2pi, 37)[1:36]
cs = [r+cos(4phi) for phi in phis, r in rs]
p = voronoiplot!(ax, phis, rs, cs, show_generators = false, strokewidth = 0)
rlims!(ax, 0.0, 10.5)
Colorbar(f[2, 2], p, vertical = false, flipaxis = false)

f

# %% 6
f = Figure(size = (800, 400))
ax1 = PolarAxis(f[1, 1], title = "No spine", spinevisible = false)
scatterlines!(ax1, range(0, 1, length=100), range(0, 10pi, length=100), color = 1:100)

ax2 = PolarAxis(f[1, 2], title = "Modified spine")
ax2.spinecolor = :red
ax2.spinestyle = :dash
ax2.spinewidth = 5
scatterlines!(ax2, range(0, 1, length=100), range(0, 10pi, length=100), color = 1:100)

f

# %% 7
f = Figure(size = (600, 600), backgroundcolor = :black)
ax = PolarAxis(
    f[1, 1],
    backgroundcolor = :black,
    # r minor grid
    rminorgridvisible = true, rminorgridcolor = :red,
    rminorgridwidth = 1.0, rminorgridstyle = :dash,
    # theta minor grid
    thetaminorgridvisible = true, thetaminorgridcolor = :lightblue,
    thetaminorgridwidth = 1.0, thetaminorgridstyle = :dash,
    # major grid
    rgridwidth = 2, rgridcolor = :red,
    thetagridwidth = 2, thetagridcolor = :lightblue,
    # r labels
    rticklabelsize = 18, rticklabelcolor = :red,
    rticklabelstrokewidth = 1.0, rticklabelstrokecolor = :white,
    # theta labels
    thetaticklabelsize = 18, thetaticklabelcolor = :lightblue
)

f

# %% 8
fig = Figure()
fullaxis(figpos, title) = PolarAxis(figpos;
                                    title,
                                    thetaminorgridvisible=true,
                                    rminorgridvisible=true,
                                    rticklabelrotation=deg2rad(-90),
                                    rticklabelsize=12,
                                    )
ax1 = fullaxis(fig[1, 1][1, 1], "all decorations")
ax2 = fullaxis(fig[1, 1][1, 2], "hide spine")
hidespines!(ax2)
ax3 = fullaxis(fig[2, 1][1, 1], "hide r decorations")
hiderdecorations!(ax3)
ax4 = fullaxis(fig[2, 1][1, 2], "hide theta decorations")
hidethetadecorations!(ax4)
ax5 = fullaxis(fig[2, 1][1, 3], "hide all decorations")
hidedecorations!(ax5)
fig

# %% 9
f = Figure()
a = PolarAxis(f[1,1],
    rticksvisible = true, thetaticksvisible = true,
    rminorticksvisible = true,
    thetaminorticksvisible = true,
)
f

# %% 10
f = Figure(size = (800, 400))
kwargs = (
    rticksvisible = true, rticksize = 12, rtickwidth = 4, rtickcolor = :red, rtickalign = 0.5,
    thetaticksvisible = true, thetaticksize = 12, thetatickwidth = 4, thetatickcolor = :blue, thetatickalign = 0.5,
    rminorticksvisible = true, rminorticksize = 8, rminortickwidth = 3, rminortickcolor = :orange, rminortickalign = 1.0,
    thetaminorticksvisible = true, thetaminorticksize = 8, thetaminortickwidth = 3, thetaminortickcolor = :cyan, thetaminortickalign = 1.0,
)
a = PolarAxis(f[1,1], title = "normal", rticksmirrored = false, thetaticksmirrored = false; kwargs...)
rlims!(a, 0.5, 0.9)
thetalims!(a, 1pi/5, 2pi/5)
a = PolarAxis(f[1,2], title = "mirrored", rticksmirrored = true, thetaticksmirrored = true; kwargs...)
rlims!(a, 0.5, 0.9)
thetalims!(a, 1pi/5, 2pi/5)
f

# %% 11
fig = Figure()
ax = PolarAxis(fig[1, 1], thetalimits = (0, pi))
lines!(ax, range(0, pi, length=100), 10 .+ sin.(0.3 .* (1:100)))
fig

# %% 12
fig = Figure()
ax = PolarAxis(fig[1, 1], thetalimits = (0, pi), radius_at_origin = 8)
lines!(ax, range(0, pi, length=100), 10 .+ sin.(0.3 .* (1:100)))
fig

# %% 13
fig = Figure()
ax = PolarAxis(fig[1, 1], thetalimits = (0, pi), radius_at_origin = -12)
lines!(ax, range(0, pi, length=100), sin.(0.3 .* (1:100)) .- 10)
fig

# %% 14
phis = range(pi/4, 9pi/4, length=201)
rs = 1.0 ./ sin.(range(pi/4, 3pi/4, length=51)[1:end-1])
rs = vcat(rs, rs, rs, rs, rs[1])

fig = Figure(size = (900, 300))
ax1 = PolarAxis(fig[1, 1], radius_at_origin = -2,  title = "radius_at_origin = -2")
ax2 = PolarAxis(fig[1, 2], radius_at_origin = 0,   title = "radius_at_origin = 0")
ax3 = PolarAxis(fig[1, 3], radius_at_origin = 0.5, title = "radius_at_origin = 0.5")
for ax in (ax1, ax2, ax3)
    lines!(ax, phis, rs .- 2, color = :red, linewidth = 4)
    lines!(ax, phis, rs, color = :black, linewidth = 4)
    lines!(ax, phis, rs .+ 0.5, color = :blue, linewidth = 4)
end
fig

# %% 15
fig = Figure(size = (600, 300))
ax1 = PolarAxis(fig[1, 1], radius_at_origin = 0.0, clip_r = true, title = "clip_r = true")
ax2 = PolarAxis(fig[1, 2], radius_at_origin = 0.0, clip_r = false, title = "clip_r = false")
for ax in (ax1, ax2)
    lines!(ax, 0..2pi, phi -> cos(2phi) - 0.5, color = :red, linewidth = 4)
    lines!(ax, 0..2pi, phi -> sin(2phi), color = :black, linewidth = 4)
end
fig
