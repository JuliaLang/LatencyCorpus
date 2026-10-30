# env: plots
# kind: unknown
# source: RecipesBase/types.md

# %% prelude
using Plots

# %% 1
using Plots, Random
Random.seed!(100)
default(legend = :topleft, markerstrokecolor = :auto, markersize = 6)

# %% 2
# defines mutable struct `UserPie` and sets shorthands `userpie` and `userpie!`
@userplot UserPie
@recipe function f(up::UserPie)
    y = up.args[end] # extract y from the args
    # if we are passed two args, we use the first as labels
    labels = length(up.args) == 2 ? up.args[1] : eachindex(y)
    framestyle --> :none
    aspect_ratio --> true
    s = sum(y)
    θ = 0
    # add a shape for each piece of pie
    for i in 1:length(y)
        # determine the angle until we stop
        θ_new = θ + 2π * y[i] / s
        # calculate the coordinates
        coords = [(0.0, 0.0); Plots.partialcircle(θ, θ_new, 50)]
        @series begin
            seriestype := :shape
            label --> string(labels[i])
            coords
        end
        θ = θ_new
    end
    # we already added all shapes in @series so we don't want to return a series
    # here. (Technically we are returning an empty series which is not added to
    # the legend.)
    primary := false
    ()
end

# %% 3
userpie('A':'D', rand(4))

# %% 4
struct MyWrapper
    v::Vector
end

# %% 5
@recipe f(::Type{MyWrapper}, mw::MyWrapper) = mw.v

# %% 6
mw = MyWrapper(cumsum(rand(10)))
plot(mw)

# %% 7
struct MyOtherWrapper
    w
end

@recipe f(::Type{MyOtherWrapper}, mow::MyOtherWrapper) = mow.w

mow = MyOtherWrapper(mw)
plot(mow)

# %% 8
struct MyTime
    h::Int
    m::Int
end

# show e.g. `MyTime(1, 30)` as "01:30"
time_string(mt) = join((lpad(string(c), 2, "0") for c in (mt.h, mt.m)), ":")
# map a `MyTime` object to the number of minutes that have passed since midnight.
# this is the actual data Plots will use.
minutes_since_midnight(mt) = 60 * mt.h + mt.m
# convert the minutes passed since midnight to a nice string showing `MyTime`
formatter(n) = time_string(MyTime(divrem(n, 60)...))

# define the recipe (it must return two functions)
@recipe f(::Type{MyTime}, mt::MyTime) = (minutes_since_midnight, formatter)

# %% 9
times = MyTime.(0:23, rand(0:59, 24))
vals = log.(1:24)

plot(times, vals)

# %% 10
plot(MyWrapper(vals), MyOtherWrapper(times))

# %% 11
@recipe function f(::Type{Val{:yscaleplot}}, plt::AbstractPlot)
    x, y = plotattributes[:x], plotattributes[:y]
    layout := (1, 2)
    for (i, scale) in enumerate((:linear, :log))
        @series begin
            title --> string(scale, " scale")
            seriestype := :path
            subplot := i
            yscale := scale
        end
    end
end

# %% 12
@shorthands yscaleplot

yscaleplot((1:10).^2)

# %% 13
yscaleplot(MyWrapper(times), MyOtherWrapper((1:24).^2))

# %% 14
userpie(rand(4, 2), layout = 2)

# %% 15
@recipe function f(::Type{Val{:seriespie}}, x, y, z)
    framestyle --> :none
    aspect_ratio --> true
    s = sum(y)
    θ = 0
    for i in eachindex(y)
        θ_new = θ + 2π * y[i] / s
        coords = [(0.0, 0.0); Plots.partialcircle(θ, θ_new, 50)]
        @series begin
            seriestype := :shape
            label --> string(x[i])
            x := first.(coords)
            y := last.(coords)
        end
        θ = θ_new
    end
end
@shorthands seriespie

# %% 16
seriespie(rand(4))

# %% 17
seriespie(MyWrapper(rand(4)))

# %% 18
seriespie(rand(4, 2), layout = 2)

# %% 19
@recipe function f(::Type{Val{:plotpie}}, plt::AbstractPlot)
    y = plotattributes[:y]
    labels = plotattributes[:x]
    framestyle --> :none
    aspect_ratio --> true
    s = sum(y)
    θ = 0
    for i in 1:length(y)
        θ_new = θ + 2π * y[i] / s
        coords = [(0.0, 0.0); Plots.partialcircle(θ, θ_new, 50)]
        @series begin
            seriestype := :shape
            label --> string(labels[i])
            x := first.(coords)
            y := last.(coords)
        end
        θ = θ_new
    end
end
@shorthands plotpie

plotpie(rand(4, 2), layout = (1, 2))

# %% 20
@recipe function f(::Type{Val{:yscaleseries}}, x, y, z)
    layout := (1, 2)
    for (i, scale) in enumerate((:linear, :log))
        @series begin
            title --> string(scale, " scale")
            seriestype := :path
            subplot := i
            yscale := scale
        end
    end
end
@shorthands yscaleseries
