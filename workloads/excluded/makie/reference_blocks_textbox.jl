# env: makie
# kind: unknown
# source: reference/blocks/textbox.md

# %% prelude
using CairoMakie

# %% 1
# pruned: failed without tiering
# %% 2

f = Figure()

tb = Textbox(f[2, 1], placeholder = "Enter a frequency",
    validator = Float64, tellwidth = false)

frequency = Observable(1.0)

on(tb.stored_string) do s
    frequency[] = parse(Float64, s)
end

xs = 0:0.01:10
sinecurve = @lift(sin.($frequency .* xs))

lines(f[1, 1], xs, sinecurve)

f
