# env: makie
# kind: interactive
# source: tutorials/getting-started.md

# %% prelude
using CairoMakie

# %% 1
using CairoMakie

# %% 2
seconds = 0:0.1:2
measurements = [8.2, 8.4, 6.3, 9.5, 9.1, 10.5, 8.6, 8.2, 10.5, 8.5, 7.2,
        8.8, 9.7, 10.8, 12.5, 11.6, 12.1, 12.1, 15.1, 14.7, 13.1]
nothing # hide

# %% 3
lines(seconds, measurements)

# %% 4
scatter(seconds, measurements)

# %% 5
lines(seconds, exp.(seconds) .+ 7)

# %% 6
scatter(seconds, measurements)
lines!(seconds, exp.(seconds) .+ 7)
current_figure()

# %% 7
f = Figure()
ax = Axis(f[1, 1])
scatter!(ax, seconds, measurements)
lines!(ax, seconds, exp.(seconds) .+ 7)
f

# %% 8
f = Figure()
ax = Axis(f[1, 1],
    title = "Experimental data and exponential fit",
    xlabel = "Time (seconds)",
    ylabel = "Value",
)
scatter!(ax, seconds, measurements)
lines!(ax, seconds, exp.(seconds) .+ 7)
f

# %% 9
f = Figure()
ax = Axis(f[1, 1],
    title = "Experimental data and exponential fit",
    xlabel = "Time (seconds)",
    ylabel = "Value",
)
scatter!(ax, seconds, measurements, color = :tomato)
lines!(ax, seconds, exp.(seconds) .+ 7, color = :tomato, linestyle = :dash)
f

# %% 10
f = Figure()
ax = Axis(f[1, 1],
    title = "Experimental data and exponential fit",
    xlabel = "Time (seconds)",
    ylabel = "Value",
)
scatter!(
    ax,
    seconds,
    measurements,
    color = :tomato,
    label = "Measurements"
)
lines!(
    ax,
    seconds,
    exp.(seconds) .+ 7,
    color = :tomato,
    linestyle = :dash,
    label = "f(x) = exp(x) + 7",
)
axislegend(position = :rb)
f

# %% 11
save("first_figure.png", f)
save("first_figure.svg", f)
save("first_figure.pdf", f)
nothing # hide
