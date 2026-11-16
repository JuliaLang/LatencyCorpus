# env: makie
# kind: unknown
# source: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/docs/src/explanations/dim-converts.md
# license: https://github.com/MakieOrg/Makie.jl/blob/v0.24.16/LICENSE.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie, Makie.Dates, Makie.Unitful
CairoMakie.activate!() # hide
Makie.inline!(true) # hide

f, ax, pl = scatter(rand(Second(1):Second(60):Second(20*60), 10))

# %% 2
scatter!(ax, rand(Hour(1):Hour(1):Hour(20), 10))
# Unitful works as well
scatter!(ax, LinRange(0u"yr", 0.1u"yr", 5))
f

# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
struct MyDimConversion <: Makie.AbstractDimConversion end

# The type you target with the dim conversion
struct MyUnit
    value::Float64
end

# This is currently needed because `expand_dimensions` can only be narrowly defined for `Vector{<:Real}` in Makie.
# So, if you want to make `plot(some_y_values)` work for your own types, you need to define this method:
Makie.expand_dimensions(::PointBased, y::AbstractVector{<:MyUnit}) = (keys(y.values), y)

function Makie.needs_tick_update_observable(conversion::MyDimConversion)
    # return an observable that indicates when ticks need to update e.g. in case the unit changes or new categories get added.
    # For a simple unit conversion this is not needed, so we return nothing.
    return nothing
end

# Indicate that this type should be converted using MyDimConversion
# The Type gets extracted via `Makie.get_element_type(plot_argument_for_dim_n)`
# so e.g. `plot(1:10, ["a", "b", "c"])` would call `Makie.get_element_type(["a", "b", "c"])` and return `String` for axis dim 2.
Makie.create_dim_conversion(::Type{MyUnit}) = MyDimConversion()

# This function needs to be overloaded too, even though it's redundant to the above in a sense.
# We did not want to use `hasmethod(Makie.should_dim_convert, (MyDimTypes,))` because it can be slow and error prown.
Makie.should_dim_convert(::Type{MyUnit}) = true

# The non observable version of the actual conversion function
# This is needed to convert axis limits, and should be a pure version of the below `convert_dim_observable`
function Makie.convert_dim_value(::MyDimConversion, values)
    return [v.value for v in values]
end

function Makie.convert_dim_value(conversion::MyDimConversion, attr, values, prev_values)
    # Do the actual conversion here
    # The `attr` can be used to identify the conversion, e.g. if you want to cache results.
    # Take a look at categorical-integration.jl for an example of how to use it.
    return Makie.convert_dim_value(conversion, values)
end

function Makie.get_ticks(::MyDimConversion, user_set_ticks, user_dim_scale, user_formatter, limits_min, limits_max)
    # Don't do anything special to ticks for this example, just append `myunit` to the labels and leave the rest to Makie's usual tick finding methods.
    ticknumbers, ticklabels = Makie.get_ticks(user_set_ticks, user_dim_scale, user_formatter, limits_min,
                                        limits_max)
    return ticknumbers, ticklabels .* "myunit"
end

barplot([MyUnit(1), MyUnit(2), MyUnit(3)], 1:3)
