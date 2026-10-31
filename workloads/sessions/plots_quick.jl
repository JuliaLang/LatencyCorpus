# env: plots
# kind: interactive
# about: Quick plots of a small table, as in a first data exploration: lines, histogram, labelled scatter, two panels, save.

# %% load
using Plots, DataFrames, Random

# %% data
rng = Xoshiro(2)
df = DataFrame(day = 1:120, temp = 15 .+ 10sin.((1:120) ./ 19) .+ randn(rng, 120),
    sales = 200 .+ 40randn(rng, 120))

# %% line plot
plot(df.day, df.temp; label = "temperature", xlabel = "day", ylabel = "°C")

# %% histogram
histogram(df.sales; bins = 20, label = "sales")

# %% labelled scatter
scatter(df.temp, df.sales; label = "", xlabel = "temperature", ylabel = "sales",
    title = "Sales against temperature")

# %% two panels
p1 = plot(df.day, df.temp; label = "temp")
p2 = bar(df.day[1:20], df.sales[1:20]; label = "sales")
plot(p1, p2; layout = (2, 1))

# %% save
savefig("two_panels.png")
filesize("two_panels.png") > 0
