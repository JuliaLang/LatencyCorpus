# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/solvers/nonautonomous_linear_ode.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
import OrdinaryDiffEqLinear as ODELinear   # LinearExponential, Magnus*, LieRK4, ...
import SciMLOperators: MatrixOperator
_A = [2 -1; -3 -5] / 5
A = MatrixOperator(_A)
prob = DE.ODEProblem(A, [1.0, -1.0], (1.0, 6.0))
sol = DE.solve(prob, ODELinear.LinearExponential())

# %% 2
function update_func!(A, u, p, t)
    A[1, 1] = cos(t)
    A[2, 1] = sin(t)
    A[1, 2] = -sin(t)
    A[2, 2] = cos(t)
    return
end
A = MatrixOperator(ones(2, 2); update_func!)
prob = DE.ODEProblem(A, ones(2), (1.0, 6.0))
sol = DE.solve(prob, ODELinear.MagnusGL6(), dt = 1 / 10)

# %% 3
function update_func!(A, u, p, t)
    A[1, 1] = 0
    A[2, 1] = sin(u[1])
    A[1, 2] = -1
    A[2, 2] = 0
    return
end
A = MatrixOperator(ones(2, 2); update_func!)
prob = DE.ODEProblem(A, ones(2), (0, 30.0))
sol = DE.solve(prob, ODELinear.LieRK4(), dt = 1 / 4)

# %% 4
function update_func!(A, u, p, t)
    A[1, 1] = 0
    A[2, 1] = 1
    A[1, 2] = -2 * (1 - cos(u[2]) - u[2] * sin(u[2]))
    A[2, 2] = 0
    return
end
A = MatrixOperator(ones(2, 2); update_func!)
prob = DE.ODEProblem(A, ones(2), (30, 150.0))
sol = DE.solve(prob, ODELinear.MagnusAdapt4())
