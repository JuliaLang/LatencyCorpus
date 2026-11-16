# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/examples/conditional_dosing.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
function f(du, u, p, t)
    du[1] = -u[1]
    return
end
u0 = [10.0]
const V = 1
prob = DE.ODEProblem(f, u0, (0.0, 10.0))

# %% 2
import Plots: plot
sol = DE.solve(prob, DE.Tsit5())
plot(sol)

# %% 3
condition(u, t, integrator) = t == 4 && u[1] / V < 4
affect!(integrator) = integrator.u[1] += 10
cb = DE.DiscreteCallback(condition, affect!)

# %% 4
sol = DE.solve(prob, DE.Tsit5(), tstops = [4.0], callback = cb)
plot(sol)

# %% 5
println(sol(4.0))
println(sol(4.000000000001))

# %% 6
function f(du, u, p, t)
    du[1] = -u[1] / 6
    return
end
u0 = [10.0]
const V = 1
prob = DE.ODEProblem(f, u0, (0.0, 10.0))

# %% 7
sol = DE.solve(prob, DE.Tsit5())
plot(sol)

# %% 8
sol = DE.solve(prob, DE.Tsit5(), tstops = [4.0], callback = cb)
plot(sol)
