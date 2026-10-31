# env: sciml
# kind: interactive
# source: tutorials/advanced_ode_example.md

# %% 1
import DifferentialEquations as DE, LinearAlgebra

const N = 32
const xyd_brusselator = range(0, stop = 1, length = N)
brusselator_f(x, y, t) = (((x - 0.3)^2 + (y - 0.6)^2) <= 0.1^2) * (t >= 1.1) * 5.0
limit(a, N) = a == N + 1 ? 1 : a == 0 ? N : a
function brusselator_2d_loop(du, u, p, t)
    A, B, α, dx = p
    α = α / dx^2
    @inbounds for I in CartesianIndices((N, N))
        i, j = Tuple(I)
        x, y = xyd_brusselator[I[1]], xyd_brusselator[I[2]]
        ip1, im1 = limit(i + 1, N), limit(i - 1, N)
        jp1, jm1 = limit(j + 1, N), limit(j - 1, N)
        du[i, j, 1] = α * (
            u[im1, j, 1] + u[ip1, j, 1] + u[i, jp1, 1] + u[i, jm1, 1] -
                4u[i, j, 1]
        ) +
            B + u[i, j, 1]^2 * u[i, j, 2] - (A + 1) * u[i, j, 1] +
            brusselator_f(x, y, t)
        du[i, j, 2] = α * (
            u[im1, j, 2] + u[ip1, j, 2] + u[i, jp1, 2] + u[i, jm1, 2] -
                4u[i, j, 2]
        ) +
            A * u[i, j, 1] - u[i, j, 1]^2 * u[i, j, 2]
    end
    return
end
p = (3.4, 1.0, 10.0, step(xyd_brusselator))

function init_brusselator_2d(xyd)
    N = length(xyd)
    u = zeros(N, N, 2)
    for I in CartesianIndices((N, N))
        x = xyd[I[1]]
        y = xyd[I[2]]
        u[I, 1] = 22 * (y * (1 - y))^(3 / 2)
        u[I, 2] = 27 * (x * (1 - x))^(3 / 2)
    end
    return u
end
u0 = init_brusselator_2d(xyd_brusselator)
prob_ode_brusselator_2d = DE.ODEProblem(brusselator_2d_loop, u0, (0.0, 11.5), p)

# %% 2
import SparseConnectivityTracer: TracerSparsityDetector
import ADTypes
detector = TracerSparsityDetector()
du0 = copy(u0)
jac_sparsity = ADTypes.jacobian_sparsity(
    (du, u) -> brusselator_2d_loop(du, u, p, 0.0), du0, u0, detector
)

# %% 3
f = DE.ODEFunction(brusselator_2d_loop; jac_prototype = float.(jac_sparsity))

# %% 4
prob_ode_brusselator_2d_sparse = DE.ODEProblem(f, u0, (0.0, 11.5), p)

# %% 5
import BenchmarkTools: @btime
import OrdinaryDiffEqSDIRK: TRBDF2, KenCarp47
import LinearSolve: KLUFactorization, UMFPACKFactorization, KrylovJL_GMRES
@btime DE.solve(prob_ode_brusselator_2d, TRBDF2(); save_everystep = false);
@btime DE.solve(prob_ode_brusselator_2d_sparse, TRBDF2(); save_everystep = false);
@btime DE.solve(
    prob_ode_brusselator_2d_sparse, KenCarp47(; linsolve = KLUFactorization());
    save_everystep = false
);
nothing # hide

# %% 6
@btime DE.solve(
    prob_ode_brusselator_2d, KenCarp47(; linsolve = KrylovJL_GMRES());
    save_everystep = false);
nothing # hide

# %% 7
import IncompleteLU: ilu, ILUFactorization
function incompletelu(W, p)
    Pl = ilu(convert(AbstractMatrix, W), τ = 50.0)
    return Pl, LinearAlgebra.I
end

# Required due to a bug in Krylov.jl: https://github.com/JuliaSmoothOptimizers/Krylov.jl/pull/477
Base.eltype(::ILUFactorization{Tv, Ti}) where {Tv, Ti} = Tv

@btime DE.solve(
    prob_ode_brusselator_2d_sparse,
    KenCarp47(;
        linsolve = KrylovJL_GMRES(precs = incompletelu),
        concrete_jac = true
    );
    save_everystep = false
);
nothing # hide

# %% 8
import AlgebraicMultigrid as AM
function algebraicmultigrid(W, p)
    A = convert(AbstractMatrix, W)
    Pl = AM.aspreconditioner(AM.ruge_stuben(A))
    return Pl, LinearAlgebra.I
end

@btime DE.solve(
    prob_ode_brusselator_2d_sparse,
    KenCarp47(;
        linsolve = KrylovJL_GMRES(precs = algebraicmultigrid),
        concrete_jac = true
    );
    save_everystep = false
);
nothing # hide

# %% 9
function algebraicmultigrid2(W, p)
    A = convert(AbstractMatrix, W)
    Pl = AM.aspreconditioner(
        AM.ruge_stuben(
            A,
            presmoother = AM.Jacobi(rand(size(A, 1))),
            postsmoother = AM.Jacobi(rand(size(A, 1)))
        )
    )
    return Pl, LinearAlgebra.I
end

@btime DE.solve(
    prob_ode_brusselator_2d_sparse,
    KenCarp47(;
        linsolve = KrylovJL_GMRES(precs = algebraicmultigrid2),
        concrete_jac = true
    );
    save_everystep = false
);
nothing # hide

# %% 10
import Sundials: CVODE_BDF
@btime DE.solve(prob_ode_brusselator_2d, CVODE_BDF(); save_everystep = false);
# Simplest speedup: use :LapackDense
@btime DE.solve(
    prob_ode_brusselator_2d, CVODE_BDF(; linear_solver = :LapackDense);
    save_everystep = false
);
# GMRES Version: Doesn't require any extra stuff!
@btime DE.solve(
    prob_ode_brusselator_2d, CVODE_BDF(; linear_solver = :GMRES);
    save_everystep = false
);
nothing # hide

# %% 11
import ModelingToolkit as MTK
prob_ode_brusselator_2d_mtk = DE.ODEProblem(
    MTK.complete(MTK.modelingtoolkitize(prob_ode_brusselator_2d_sparse)),
    [], (0.0, 11.5); jac = true, sparse = true
);
# @btime DE.solve(prob_ode_brusselator_2d_mtk, CVODE_BDF(linear_solver=:KLU), save_everystep=false); # compiles very slowly
nothing # hide
