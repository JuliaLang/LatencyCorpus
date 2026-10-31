# env: makie
# kind: interactive
# source: explanations/figure.md

# %% prelude
using CairoMakie

# %% 1
f = Figure()
pos = f[1, 1]
scatter(pos, rand(100, 2))

pos2 = f[1, 2]
lines(pos2, cumsum(randn(100)))

# you don't have to store the position in a variable first, of course
heatmap(f[1, 3], randn(10, 10))

f

# %% 2
f = Figure()

f[1, 1] = Axis(f, title = "I'm not nested")
f[1, 2][1, 1] = Axis(f, title = "I'm nested")

# plotting into nested positions also works
heatmap(f[1, 2][2, 1], randn(20, 20))

f

# %% 3
f = Figure(figure_padding = 1, backgroundcolor = :gray80)

Axis(f[1, 1])
scatter!(1:10)

f

# %% 4
using CairoMakie
CairoMakie.activate!()

sets = [
    (; title = "px_per_unit", px_per_units = [0.5, 1, 2], sizes = [50, 50, 50]),
    (; title = "figure_size", px_per_units = [2, 2, 2], sizes = [25, 50, 100]),
]

for (; title, px_per_units, sizes) in sets
    f = Figure(size = (600, 500))

    pixel_axes = Axis[]
    for (i, (ppu, size)) in enumerate(zip(px_per_units, sizes))
        bitmap = colorbuffer(let
            _f = Figure(size = (size, size), fontsize = 6, figure_padding = 3, backgroundcolor = :tomato)
            ax = Axis(_f[1, 1], title = "Abc", titlegap = 1)
            lines!(ax, sin.(range(0, 7pi, 100)) .+ range(0, 10, 100))
            hidedecorations!(ax)
            _f
        end; px_per_unit = ppu)
        bm = rotr90(bitmap)
        npix = Base.size(bm, 1)
        interval = (1, npix) .- (npix+1)/2

        ax, im = image(f[1, i], interval, interval, bm, interpolate = false, axis = (; autolimitaspect = 1))

        px_title = rich("px_per_unit = $ppu", color = allequal(px_per_units) ? :gray60 : :black)
        size_title = rich("size = ($size, $size)", color = allequal(sizes) ? :gray60 : :black)
        ax.title = rich(size_title, "\n", px_title)

        push!(pixel_axes, ax)
        hidedecorations!(ax)
        hidespines!(ax)
        ax.xlabelvisible = true
        ax.xlabel = "$(join(Base.size(bm), " x ")) px"
        ax.xlabelfont = :italic

        ax2, im2 = image(f[2, i], rotr90(bitmap), interpolate = false, axis = (; autolimitaspect = 1, backgroundcolor = "#f5f2eb"))
        ax2.xautolimitmargin = (0.1, 0.1)
        ax2.yautolimitmargin = (0.1, 0.1)
        hidedecorations!(ax2)
        hidespines!(ax2)
        text!(ax2, 0, 1, space = :relative, align = (:left, :top),
            text = "Lorem ipsum dolor sit amet\nconsetetur sadipscing elitr,",
            offset = (10, -10), fontsize = 12, font = :italic, color = :gray50)
        text!(ax2, 0, 0, space = :relative, align = (:left, :bottom),
            text = "sed diam nonumy eirmod\ninvidunt ut labore et dolore",
            offset = (10, 10), fontsize = 12, font = :italic, color = :gray50)
    end
    linkaxes!(pixel_axes...)
    rowsize!(f.layout, 1, Aspect(1, 1))

    Label(f[1, 0], "Relative bitmap size", font = :bold, rotation = pi/2, tellheight = false)
    Label(f[2, 0], "Scaled to same apparent size", font = :bold, rotation = pi/2, tellheight = false)

    save("$title.png", f)
end
