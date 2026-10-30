# env: makie
# kind: unknown
# source: reference/plots/scatter.md

# %% prelude
using CairoMakie

# %% 1
xs = range(0, 10, length = 30)
ys = 0.5 .* sin.(xs)

scatter(xs, ys)

# %% 2
xs = range(0, 10, length = 30)
ys = 0.5 .* sin.(xs)
points = Point2f.(xs, ys)

scatter(points, color = 1:30, markersize = range(5, 30, length = 30),
    colormap = :thermal)

# %% 3
markers_labels = [
    (:circle, ":circle"),
    (:rect, ":rect"),
    (:diamond, ":diamond"),
    (:hexagon, ":hexagon"),
    (:cross, ":cross"),
    (:xcross, ":xcross"),
    (:utriangle, ":utriangle"),
    (:dtriangle, ":dtriangle"),
    (:ltriangle, ":ltriangle"),
    (:rtriangle, ":rtriangle"),
    (:pentagon, ":pentagon"),
    (:star4, ":star4"),
    (:star5, ":star5"),
    (:star6, ":star6"),
    (:star8, ":star8"),
    (:vline, ":vline"),
    (:hline, ":hline"),
    ('a', "'a'"),
    ('B', "'B'"),
    ('↑', "'\\uparrow'"),
    ('😄', "'\\:smile:'"),
    ('✈', "'\\:airplane:'"),
]

f = Figure()
ax = Axis(f[1, 1], yreversed = true,
    xautolimitmargin = (0.15, 0.15),
    yautolimitmargin = (0.15, 0.15)
)
hidedecorations!(ax)

for (i, (marker, label)) in enumerate(markers_labels)
    p = Point2f(fldmod1(i, 6)...)

    scatter!(p, marker = marker, markersize = 20, color = :black)
    text!(p, text = label, color = :gray70, offset = (0, 20),
        align = (:center, :bottom))
end

f

# %% 4
f, ax, sc = scatter(1, 1, marker = 'A', markersize = 50)
text!(2, 1, text = "A", fontsize = 50, align = (:center, :center))
xlims!(ax, -1, 4)
f

# %% 5
f, ax, l = lines([0, 1], [1, 1], linewidth = 50, color = :gray80)
for (marker, x) in zip(['X', 'x', :circle, :rect, :utriangle, Circle, Rect], range(0.1, 0.9, length = 7))
    scatter!(ax, x, 1, marker = marker, markersize = 50, color = :black)
end
f

# %% 6
hexagon = Makie.Polygon([Point2f(cos(a), sin(a)) for a in range(1/6 * pi, 13/6 * pi, length = 7)])

points = Point2f[(0, 0), (sqrt(3), 0), (sqrt(3)/2, 1.5)]

scatter(points,
    marker = hexagon,
    markersize = 1,
    markerspace = :data,
    color = 1:3,
    axis = (; aspect = 1, limits = (-2, 4, -2, 4)))

# %% 7
arrow_path = BezierPath([
    MoveTo(Point(0, 0)),
    LineTo(Point(0.3, -0.3)),
    LineTo(Point(0.15, -0.3)),
    LineTo(Point(0.3, -1)),
    LineTo(Point(0, -0.9)),
    LineTo(Point(-0.3, -1)),
    LineTo(Point(-0.15, -0.3)),
    LineTo(Point(-0.3, -0.3)),
    ClosePath()
])

scatter(1:5,
    marker = arrow_path,
    markersize = range(20, 50, length = 5),
    rotation = range(0, 2pi, length = 6)[1:end-1],
)

# %% 8
heart = BezierPath([
    MoveTo(Point(0, -1)),
    CurveTo(Point(-1.5, -0.4), Point(-0.6, 1.2), Point(0, 0)),
    CurveTo(Point(0.6, 1.2), Point(1.5, -0.4), Point(0, -1)),
    ClosePath()
])

on_curve = Point2f[(0, -1), (0, 0)]
controls = Point2f[(-1.5, -0.4), (-0.6, 1.2)]

f = Figure()
ax = Axis(f[1, 1], aspect = 1)

scatter!(ax, Point2f(0, 0), marker = heart, markersize = 1,
    markerspace = :data, color = (:red, 0.3), strokewidth = 2, strokecolor = :red)

for (from, to) in zip(on_curve, controls)
    lines!(ax, [from, to], color = :gray60, linestyle = :dash)
end
scatter!(ax, controls, color = :gray60, markersize = 10)
scatter!(ax, on_curve, color = :black, markersize = 12)

annotation!(ax, controls, text = ["control point 1", "control point 2"], fontsize = 12)
annotation!(ax, on_curve, text = ["on-curve point 1", "on-curve point 2"], fontsize = 12)

f

# %% 9
circle_with_hole = BezierPath([
    MoveTo(Point(1, 0)),
    EllipticalArc(Point(0, 0), 1, 1, 0, 0, 2pi),
    MoveTo(Point(0.5, 0.5)),
    LineTo(Point(0.5, -0.5)),
    LineTo(Point(-0.5, -0.5)),
    LineTo(Point(-0.5, 0.5)),
    ClosePath(),
])

scatter(1:5,
    marker = circle_with_hole,
    markersize = 30,
)

# %% 10
batsymbol_string = "M96.84 141.998c-4.947-23.457-20.359-32.211-25.862-13.887-11.822-22.963-37.961-16.135-22.041 6.289-3.005-1.295-5.872-2.682-8.538-4.191-8.646-5.318-15.259-11.314-19.774-17.586-3.237-5.07-4.994-10.541-4.994-16.229 0-19.774 21.115-36.758 50.861-43.694.446-.078.909-.154 1.372-.231-22.657 30.039 9.386 50.985 15.258 24.645l2.528-24.367 5.086 6.52H103.205l5.07-6.52 2.543 24.367c5.842 26.278 37.746 5.502 15.414-24.429 29.777 6.951 50.891 23.936 50.891 43.709 0 15.136-12.406 28.651-31.609 37.267 14.842-21.822-10.867-28.266-22.549-5.549-5.502-18.325-21.147-9.341-26.125 13.886z"

batsymbol = BezierPath(batsymbol_string, fit = true, flipy = true)

scatter(1:10, marker = batsymbol, markersize = 50, color = :black)

# %% 11
using GeometryBasics
p_big = decompose(Point2f, Circle(Point2f(0), 1))
p_small = decompose(Point2f, Circle(Point2f(0), 0.5))
scatter(1:4, fill(0, 4), marker=Polygon(p_big, [p_small]), markersize=100, color=1:4, axis=(limits=(0, 5, -1, 1),))

# %% 12
f = Figure()
ax = Axis(f[1, 1])

scales = range(0.5, 1.5, length = 10)

for (i, sx) in enumerate(scales)
    for (j, sy) in enumerate(scales)
        scatter!(ax, Point2f(i, j),
            marker = '✈',
            markersize = 30 .* Vec2f(sx, sy),
            color = :black)
    end
end

f

# %% 13
f = Figure()
ax = Axis(f[1, 1])
limits!(ax, -10, 10, -10, 10)

scatter!(ax, Point2f(0, 0), markersize = 20, markerspace = :data,
    marker = '✈', label = "markerspace = :data")
scatter!(ax, Point2f(0, 0), markersize = 20, markerspace = :pixel,
    marker = '✈', label = "markerspace = :pixel")

axislegend(ax)

f

# %% 14
using DelimitedFiles


a = readdlm(assetpath("airportlocations.csv"))

scatter(a[1:50:end, :], marker = '✈',
    markersize = 20, color = :black)
