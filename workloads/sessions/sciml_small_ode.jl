# env: sciml
# kind: interactive
# about: A small ODE at the REPL, as SciPy users do with solve_ivp: define, solve, plot, change a parameter, solve again.

# %% load
using OrdinaryDiffEq, Plots

# %% define and solve
function lotka!(du, u, p, t)
    a, b, c, d = p
    du[1] = a * u[1] - b * u[1] * u[2]
    du[2] = -c * u[2] + d * u[1] * u[2]
end
prob = ODEProblem(lotka!, [1.0, 1.0], (0.0, 10.0), [1.5, 1.0, 3.0, 1.0])
sol = solve(prob, Tsit5())

# %% plot
plot(sol; labels = ["prey" "predator"])

# %% value at a time
sol(5.0)

# %% another parameter
sol2 = solve(remake(prob; p = [1.5, 1.0, 2.0, 1.0]), Tsit5())
plot(sol2; idxs = (1, 2), label = "phase portrait")
