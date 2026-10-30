# env: makie
# kind: unknown
# source: explanations/latex.md

# %% prelude
using CairoMakie

# %% 1
f = Figure(fontsize = 18)

Axis(f[1, 1],
    title = L"\forall \mathcal{X} \in \mathbb{R} \quad \frac{x + y}{\sin(k^2)}",
    xlabel = L"\sum_a^b{xy} + \mathscr{L}",
    ylabel = L"\sqrt{\frac{a}{b}} - \mathfrak{W}"
)

f

# %% 2
f = Figure(fontsize = 18)
t = "text"
Axis(f[1,1], title=L"Some %$(t) and some math: $\frac{2\alpha+1}{y}$")

f

# %% 3
with_theme(theme_latexfonts()) do
    fig = Figure()
    Label(fig[1, 1], "A standard Label", tellwidth = false)
    Label(fig[2, 1], L"A LaTeXString with a small formula $x^2$", tellwidth = false)
    Axis(fig[3, 1], title = "An axis with matching font for the tick labels")
    fig
end
