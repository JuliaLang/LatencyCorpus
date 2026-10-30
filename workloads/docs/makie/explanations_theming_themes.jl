# env: makie
# kind: unknown
# source: explanations/theming/themes.md

# %% prelude
using CairoMakie

# %% 1
function example_plot()
    f = Figure()
    for i in 1:2, j in 1:2
        lines(f[i, j], cumsum(randn(50)))
    end
    Label(f[0, :], "A simple example plot")
    Label(f[3, :], L"Random walks $x(t_n)$")
    f
end

example_plot()

# %% 2
fontsize_theme = Theme(fontsize = 10)
set_theme!(fontsize_theme)

example_plot()

# %% 3
set_theme!()
nothing # hide

# %% 4
dark_latexfonts = merge(theme_dark(), theme_latexfonts())
with_theme(dark_latexfonts) do
    example_plot()
end

# %% 5
update_theme!(fontsize=30)
example_plot()

# %% 6
set_theme!() # hide
with_theme(fontsize_theme) do
    example_plot()
end

# %% 7
with_theme(fontsize_theme, fontsize = 25) do
    example_plot()
end

# %% 8
lines_theme = Theme(
    Lines = (
        linewidth = 4,
        linestyle = :dash,
    )
)

with_theme(example_plot, lines_theme)

# %% 9
ggplot_theme = Theme(
    Axis = (
        backgroundcolor = :gray90,
        leftspinevisible = false,
        rightspinevisible = false,
        bottomspinevisible = false,
        topspinevisible = false,
        xgridcolor = :white,
        ygridcolor = :white,
    )
)

with_theme(example_plot, ggplot_theme)

# %% 10
with_theme(
    Theme(
        palette = (color = [:red, :blue], marker = [:circle, :xcross]),
        Scatter = (cycle = [:color, :marker],)
    )) do
    scatter(fill(1, 10))
    scatter!(fill(2, 10))
    scatter!(fill(3, 10))
    scatter!(fill(4, 10))
    scatter!(fill(5, 10))
    current_figure()
end

# %% 11
with_theme(
    Theme(
        palette = (color = [:red, :blue], linestyle = [:dash, :dot]),
        Lines = (cycle = Cycle([:color, :linestyle], covary = true),)
    )) do
    lines(fill(5, 10))
    lines!(fill(4, 10))
    lines!(fill(3, 10))
    lines!(fill(2, 10))
    lines!(fill(1, 10))
    current_figure()
end

# %% 12
f = Figure()

Axis(f[1, 1])

# the normal cycle
lines!(0..10, x -> sin(x) - 1)
lines!(0..10, x -> sin(x) - 2)
lines!(0..10, x -> sin(x) - 3)

# manually specified colors
lines!(0..10, x -> sin(x) - 5, color = Cycled(3))
lines!(0..10, x -> sin(x) - 6, color = Cycled(2))
lines!(0..10, x -> sin(x) - 7, color = Cycled(1))

f

# %% 13
set_theme!() # hide

f = Figure(size = (800, 800))

Axis(f[1, 1], title = "Default cycle palette")

for i in 1:6
    density!(randn(50) .+ 2i)
end

Axis(f[2, 1],
    title = "Custom cycle palette",
    palette = (patchcolor = [:red, :green, :blue, :yellow, :orange, :pink],))

for i in 1:6
    density!(randn(50) .+ 2i)
end

set_theme!(Density = (cycle = [],))

Axis(f[3, 1], title = "No cycle")

for i in 1:6
    density!(randn(50) .+ 2i)
end

set_theme!() # hide

f
