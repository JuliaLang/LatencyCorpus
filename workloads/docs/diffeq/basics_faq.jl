# env: sciml
# kind: unknown
# source: basics/faq.md

# %% 1
import DifferentialEquations as DE
function func(du, u, p, t)
    du[1] = p[1] * u[1] - p[2] * u[1] * u[2]
    du[2] = -3 * u[2] + u[1] * u[2]
    return
end
function f(p)
    prob = DE.ODEProblem(func, eltype(p).([1.0, 1.0]), (0.0, 10.0), p)
    # Lower tolerances to show the methods converge to the same value
    sol = DE.solve(prob, DE.Tsit5(), save_everystep = false, abstol = 1.0e-12, reltol = 1.0e-12)
    return sol.u[end]
end

# %% 2
import ForwardDiff
ForwardDiff.jacobian(f, [1.5, 1.0])

# %% 3
import FiniteDiff
FiniteDiff.finite_difference_jacobian(f, [1.5, 1.0])
