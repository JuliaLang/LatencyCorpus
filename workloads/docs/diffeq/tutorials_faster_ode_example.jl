# env: sciml
# kind: unknown
# source: tutorials/faster_ode_example.md

# %% 1
function lorenz(u, p, t)
    dx = 10.0 * (u[2] - u[1])
    dy = u[1] * (28.0 - u[3]) - u[2]
    dz = u[1] * u[2] - (8 / 3) * u[3]
    return [dx, dy, dz]
end

# %% 2
import DifferentialEquations as DE
import BenchmarkTools: @btime
u0 = [1.0; 0.0; 0.0]
tspan = (0.0, 100.0)
prob = DE.ODEProblem(lorenz, u0, tspan)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 3
@btime DE.solve(prob, DE.Tsit5(); save_everystep = false);
nothing # hide

# %% 4
function lorenz!(du, u, p, t)
    du[1] = 10.0 * (u[2] - u[1])
    du[2] = u[1] * (28.0 - u[3]) - u[2]
    du[3] = u[1] * u[2] - (8 / 3) * u[3]
    return
end

# %% 5
u0 = [1.0; 0.0; 0.0]
tspan = (0.0, 100.0)
prob = DE.ODEProblem(lorenz!, u0, tspan)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 6
@btime DE.solve(prob, DE.Tsit5(); save_everystep = false);
nothing # hide

# %% 7
tspan = (0.0, 500.0) # 5x longer than before
prob = DE.ODEProblem(lorenz!, u0, tspan)
@btime DE.solve(prob, DE.Tsit5(); save_everystep = false);
nothing # hide

# %% 8
import StaticArrays: SA
A = SA[2.0, 3.0, 5.0]
typeof(A)

# %% 9
function lorenz_static(u, p, t)
    dx = 10.0 * (u[2] - u[1])
    dy = u[1] * (28.0 - u[3]) - u[2]
    dz = u[1] * u[2] - (8 / 3) * u[3]
    return SA[dx, dy, dz]
end

# %% 10
u0 = SA[1.0, 0.0, 0.0]
tspan = (0.0, 100.0)
prob = DE.ODEProblem(lorenz_static, u0, tspan)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 11
@btime DE.solve(prob, DE.Tsit5(); save_everystep = false);
nothing # hide

# %% 12
import DifferentialEquations as DE
import Plots: plot
function rober!(du, u, p, t)
    y₁, y₂, y₃ = u
    k₁, k₂, k₃ = p
    du[1] = -k₁ * y₁ + k₃ * y₂ * y₃
    du[2] = k₁ * y₁ - k₂ * y₂^2 - k₃ * y₂ * y₃
    du[3] = k₂ * y₂^2
    return
end
prob = DE.ODEProblem(rober!, [1.0, 0.0, 0.0], (0.0, 1.0e5), [0.04, 3.0e7, 1.0e4])
sol = DE.solve(prob)
plot(sol, tspan = (1.0e-2, 1.0e5), xscale = :log10)

# %% 13
import BenchmarkTools: @btime
@btime DE.solve(prob);
nothing # hide

# %% 14
@btime DE.solve(prob, DE.Rosenbrock23());
nothing # hide

# %% 15
function rober_jac!(J, u, p, t)
    y₁, y₂, y₃ = u
    k₁, k₂, k₃ = p
    J[1, 1] = k₁ * -1
    J[2, 1] = k₁
    J[3, 1] = 0
    J[1, 2] = y₃ * k₃
    J[2, 2] = y₂ * k₂ * -2 + y₃ * k₃ * -1
    J[3, 2] = y₂ * 2 * k₂
    J[1, 3] = k₃ * y₂
    J[2, 3] = k₃ * y₂ * -1
    J[3, 3] = 0
    return
end
f! = DE.ODEFunction(rober!, jac = rober_jac!)
prob_jac = DE.ODEProblem(f!, [1.0, 0.0, 0.0], (0.0, 1.0e5), (0.04, 3.0e7, 1.0e4))

# %% 16
@btime DE.solve(prob_jac, DE.Rosenbrock23());
nothing # hide

# %% 17
import ModelingToolkit as MTK
de = MTK.complete(MTK.modelingtoolkitize(prob))

# %% 18
MTK.generate_jacobian(de)[2] # Second is in-place

# %% 19
prob_jac2 = DE.ODEProblem(de, [], (0.0, 1.0e5); jac = true)

# %% 20
@btime DE.solve(prob_jac2);
nothing # hide

# %% 21
import StaticArrays: SA
function rober_static(u, p, t)
    y₁, y₂, y₃ = u
    k₁, k₂, k₃ = p
    du1 = -k₁ * y₁ + k₃ * y₂ * y₃
    du2 = k₁ * y₁ - k₂ * y₂^2 - k₃ * y₂ * y₃
    du3 = k₂ * y₂^2
    return SA[du1, du2, du3]
end
prob = DE.ODEProblem(
    rober_static, SA[1.0, 0.0, 0.0], (0.0, 1.0e5), SA[0.04, 3.0e7, 1.0e4]
)
sol = DE.solve(prob, DE.Rosenbrock23())

# %% 22
@btime sol = DE.solve(prob, DE.Rosenbrock23());
nothing # hide

# %% 23
import DifferentialEquations as DE, LinearAlgebra as LA
import BenchmarkTools: @btime
# Generate the constants
p = (1.0, 1.0, 1.0, 10.0, 0.001, 100.0) # a,α,ubar,β,D1,D2
N = 100
Ax = Array(
    LA.Tridiagonal(
        [1.0 for i in 1:(N - 1)],
        [-2.0 for i in 1:N],
        [1.0 for i in 1:(N - 1)]
    )
)
Ay = copy(Ax)
Ax[2, 1] = 2.0
Ax[end - 1, end] = 2.0
Ay[1, 2] = 2.0
Ay[end, end - 1] = 2.0

function basic_version!(dr, r, p, t)
    a, α, ubar, β, D1, D2 = p
    u = r[:, :, 1]
    v = r[:, :, 2]
    Du = D1 * (Ay * u + u * Ax)
    Dv = D2 * (Ay * v + v * Ax)
    dr[:, :, 1] = Du .+ a .* u .* u ./ v .+ ubar .- α * u
    dr[:, :, 2] = Dv .+ a .* u .* u .- β * v
    return
end

a, α, ubar, β, D1, D2 = p
uss = (ubar + β) / α
vss = (a / β) * uss^2
r0 = zeros(100, 100, 2)
r0[:, :, 1] .= uss .+ 0.1 .* rand.()
r0[:, :, 2] .= vss

prob = DE.ODEProblem(basic_version!, r0, (0.0, 0.1), p)

# %% 24
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 25
A = rand(4)
@show A
B = @view A[1:3]
B[2] = 2
@show A

# %% 26
function gm2!(dr, r, p, t)
    a, α, ubar, β, D1, D2 = p
    u = @view r[:, :, 1]
    v = @view r[:, :, 2]
    du = @view dr[:, :, 1]
    dv = @view dr[:, :, 2]
    Du = D1 * (Ay * u + u * Ax)
    Dv = D2 * (Ay * v + v * Ax)
    @. du = Du + a .* u .* u ./ v + ubar - α * u
    @. dv = Dv + a .* u .* u - β * v
    return
end
prob = DE.ODEProblem(gm2!, r0, (0.0, 0.1), p)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 27
Ayu = zeros(N, N)
uAx = zeros(N, N)
Du = zeros(N, N)
Ayv = zeros(N, N)
vAx = zeros(N, N)
Dv = zeros(N, N)
function gm3!(dr, r, p, t)
    a, α, ubar, β, D1, D2 = p
    u = @view r[:, :, 1]
    v = @view r[:, :, 2]
    du = @view dr[:, :, 1]
    dv = @view dr[:, :, 2]
    LA.mul!(Ayu, Ay, u)
    LA.mul!(uAx, u, Ax)
    LA.mul!(Ayv, Ay, v)
    LA.mul!(vAx, v, Ax)
    @. Du = D1 * (Ayu + uAx)
    @. Dv = D2 * (Ayv + vAx)
    @. du = Du + a * u * u ./ v + ubar - α * u
    @. dv = Dv + a * u * u - β * v
    return
end
prob = DE.ODEProblem(gm3!, r0, (0.0, 0.1), p)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 28
p = (1.0, 1.0, 1.0, 10.0, 0.001, 100.0, Ayu, uAx, Du, Ayv, vAx, Dv) # a,α,ubar,β,D1,D2
function gm4!(dr, r, p, t)
    a, α, ubar, β, D1, D2, Ayu, uAx, Du, Ayv, vAx, Dv = p
    u = @view r[:, :, 1]
    v = @view r[:, :, 2]
    du = @view dr[:, :, 1]
    dv = @view dr[:, :, 2]
    LA.mul!(Ayu, Ay, u)
    LA.mul!(uAx, u, Ax)
    LA.mul!(Ayv, Ay, v)
    LA.mul!(vAx, v, Ax)
    @. Du = D1 * (Ayu + uAx)
    @. Dv = D2 * (Ayv + vAx)
    @. du = Du + a * u * u ./ v + ubar - α * u
    @. dv = Dv + a * u * u - β * v
    return
end
prob = DE.ODEProblem(gm4!, r0, (0.0, 0.1), p)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 29
p = (1.0, 1.0, 1.0, 10.0, 0.001, 100.0, N)
function fast_gm!(du, u, p, t)
    a, α, ubar, β, D1, D2, N = p

    @inbounds for j in 2:(N - 1), i in 2:(N - 1)

        du[i, j, 1] = D1 *
            (
            u[i - 1, j, 1] + u[i + 1, j, 1] + u[i, j + 1, 1] + u[i, j - 1, 1] -
                4u[i, j, 1]
        ) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
    end

    @inbounds for j in 2:(N - 1), i in 2:(N - 1)

        du[i, j, 2] = D2 *
            (
            u[i - 1, j, 2] + u[i + 1, j, 2] + u[i, j + 1, 2] + u[i, j - 1, 2] -
                4u[i, j, 2]
        ) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end

    @inbounds for j in 2:(N - 1)
        i = 1
        du[1, j, 1] = D1 *
            (2u[i + 1, j, 1] + u[i, j + 1, 1] + u[i, j - 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
    end
    @inbounds for j in 2:(N - 1)
        i = 1
        du[1, j, 2] = D2 *
            (2u[i + 1, j, 2] + u[i, j + 1, 2] + u[i, j - 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end
    @inbounds for j in 2:(N - 1)
        i = N
        du[end, j, 1] = D1 *
            (2u[i - 1, j, 1] + u[i, j + 1, 1] + u[i, j - 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
    end
    @inbounds for j in 2:(N - 1)
        i = N
        du[end, j, 2] = D2 *
            (2u[i - 1, j, 2] + u[i, j + 1, 2] + u[i, j - 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end

    @inbounds for i in 2:(N - 1)
        j = 1
        du[i, 1, 1] = D1 *
            (u[i - 1, j, 1] + u[i + 1, j, 1] + 2u[i, j + 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
    end
    @inbounds for i in 2:(N - 1)
        j = 1
        du[i, 1, 2] = D2 *
            (u[i - 1, j, 2] + u[i + 1, j, 2] + 2u[i, j + 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end
    @inbounds for i in 2:(N - 1)
        j = N
        du[i, end, 1] = D1 *
            (u[i - 1, j, 1] + u[i + 1, j, 1] + 2u[i, j - 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
    end
    @inbounds for i in 2:(N - 1)
        j = N
        du[i, end, 2] = D2 *
            (u[i - 1, j, 2] + u[i + 1, j, 2] + 2u[i, j - 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end

    @inbounds begin
        i = 1
        j = 1
        du[1, 1, 1] = D1 * (2u[i + 1, j, 1] + 2u[i, j + 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
        du[1, 1, 2] = D2 * (2u[i + 1, j, 2] + 2u[i, j + 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]

        i = 1
        j = N
        du[1, N, 1] = D1 * (2u[i + 1, j, 1] + 2u[i, j - 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
        du[1, N, 2] = D2 * (2u[i + 1, j, 2] + 2u[i, j - 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]

        i = N
        j = 1
        du[N, 1, 1] = D1 * (2u[i - 1, j, 1] + 2u[i, j + 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
        du[N, 1, 2] = D2 * (2u[i - 1, j, 2] + 2u[i, j + 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]

        i = N
        j = N
        du[end, end, 1] = D1 * (2u[i - 1, j, 1] + 2u[i, j - 1, 1] - 4u[i, j, 1]) +
            a * u[i, j, 1]^2 / u[i, j, 2] + ubar - α * u[i, j, 1]
        du[end, end, 2] = D2 * (2u[i - 1, j, 2] + 2u[i, j - 1, 2] - 4u[i, j, 2]) +
            a * u[i, j, 1]^2 - β * u[i, j, 2]
    end
    return
end
prob = DE.ODEProblem(fast_gm!, r0, (0.0, 0.1), p)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 30
import ModelingToolkit as MTK
function basic_version!(dr, r, p, t)
    a, α, ubar, β, D1, D2 = p
    u = r[:, :, 1]
    v = r[:, :, 2]
    Du = D1 * (Ay * u + u * Ax)
    Dv = D2 * (Ay * v + v * Ax)
    dr[:, :, 1] = Du .+ a .* u .* u ./ v .+ ubar .- α * u
    dr[:, :, 2] = Dv .+ a .* u .* u .- β * v
    return
end

a, α, ubar, β, D1, D2 = p
uss = (ubar + β) / α
vss = (a / β) * uss^2
r0 = zeros(100, 100, 2)
r0[:, :, 1] .= uss .+ 0.1 .* rand.()
r0[:, :, 2] .= vss

prob = DE.ODEProblem(basic_version!, r0, (0.0, 0.1), p)
de = MTK.complete(MTK.modelingtoolkitize(prob))

# Note jac=true,sparse=true makes it automatically build sparse Jacobian code
# as well!

fastprob = DE.ODEProblem(de, [], (0.0, 0.1); jac = true, sparse = true)

# %% 31
prob = DE.ODEProblem(fast_gm!, r0, (0.0, 10.0), p)
@btime DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 32
import Sundials: CVODE_BDF
@btime DE.solve(prob, CVODE_BDF(; linear_solver = :GMRES));
nothing # hide

# %% 33
prob = DE.ODEProblem(fast_gm!, r0, (0.0, 100.0), p)
# Will go out of memory if we don't turn off `save_everystep`!
@btime DE.solve(prob, DE.Tsit5(); save_everystep = false);
nothing # hide

# %% 34
@btime DE.solve(prob, CVODE_BDF(; linear_solver = :GMRES); save_everystep = false);
nothing # hide

# %% 35
prob = DE.ODEProblem(fast_gm!, r0, (0.0, 500.0), p)
@btime DE.solve(prob, CVODE_BDF(; linear_solver = :GMRES); save_everystep = false);
nothing # hide
