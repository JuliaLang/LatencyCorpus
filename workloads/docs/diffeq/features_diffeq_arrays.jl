# env: sciml
# kind: interactive
# source: features/diffeq_arrays.md

# %% 1
import DifferentialEquations as DE
import RecursiveArrayTools: ArrayPartition
import LinearAlgebra: norm
import Unitful: @u_str      # Use units as u"..."

r0 = [1131.34, -2282.343, 6672.423]u"km"
v0 = [-5.64305, 4.30333, 2.42879]u"km/s"
Δt = 86400.0 * 365u"s"
μ = 398600.4418u"km^3/s^2"
rv0 = ArrayPartition(r0, v0)

# %% 2
function f(dy, y, μ, t)
    r = norm(y.x[1])
    dy.x[1] .= y.x[2]
    dy.x[2] .= -μ .* y.x[1] / r^3
    return
end

# %% 3
prob = DE.ODEProblem(f, rv0, (0.0u"s", Δt), μ)
sol = DE.solve(prob, DE.Vern8())
