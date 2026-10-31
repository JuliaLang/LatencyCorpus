# env: sciml
# kind: overcompile
# source: basics/FAQ.md

# %% 1
using ModelingToolkit

@parameters p q[1:3] r[1:2, 1:2]

@named sys = System(Equation[], ModelingToolkit.t_nounits, [], [p, q, r])
sys = complete(sys)

# %% 2
using SciMLStructures: canonicalize, Tunable

ps = MTKParameters(sys, [p => 1.0, q => [2.0, 3.0, 4.0], r => [5.0 6.0; 7.0 8.0]])
arr = canonicalize(Tunable(), ps)[1]

# %% 3
reorder_dimension_by_tunables(sys, arr, [p, q, r])

# %% 4
reorder_dimension_by_tunables(sys, arr, [q[1], r[1, :], q[2], r[2, :], q[3], p])

# %% 5
highdimarr = stack([i * arr for i in 1:5]; dims = 1)

# %% 6
reorder_dimension_by_tunables(sys, highdimarr, [q[1:2], r[1, :], q[3], r[2, :], p]; dim = 2)
