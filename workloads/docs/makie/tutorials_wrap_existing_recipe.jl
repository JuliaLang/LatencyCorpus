# env: makie
# kind: unknown
# source: tutorials/wrap-existing-recipe.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie
CairoMakie.activate!() # hide

struct MyHist
    bincounts
    bincenters
end

nothing # hide

# %% 2
Makie.convert_arguments(P::Type{<:BarPlot}, h::MyHist) = convert_arguments(P, h.bincenters, h.bincounts)
nothing # hide

# %% 3
h = MyHist([1, 10, 100], 1:3)

barplot(h)

# %% 4
function Makie.plot!(plot::Hist{<:Tuple{<:MyHist}})
    barplot!(plot, plot[1])
    plot
end
h = MyHist([1, 10, 100], 1:3)
hist(h; color=:red, direction=:x)

# %% 5
function Makie.plot!(plot::Hist{<:Tuple{<:MyHist}})
    # Only forward valid attributes for BarPlot
    valid_attributes = Makie.shared_attributes(plot, BarPlot)
    barplot!(plot, valid_attributes, plot[1])
end
h = MyHist([1, 10, 100], 1:3)
hist(h; color=:red, direction=:x)
