# env: sciml
# kind: unknown
# source: features/io.md

# %% 1
import OrdinaryDiffEq as ODE
import OrdinaryDiffEqLowOrderRK: Euler
import DataFrames: DataFrame
f_2dlinear = (du, u, p, t) -> du .= 1.01u;
tspan = (0.0, 1.0)
prob = ODE.ODEProblem(f_2dlinear, rand(2, 2), tspan);
sol = ODE.solve(prob, Euler(); dt = 1 // 2^(4));
df = DataFrame(sol)

# %% 2
df = DataFrame(sol)

# %% 3
import CSV
CSV.write("out.csv", df)

# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
