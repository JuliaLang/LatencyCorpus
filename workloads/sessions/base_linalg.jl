# env: base
# kind: interactive
# about: Small linear algebra at the REPL: solve a system, factorize, least squares, eigenvalues.

# %% load
using LinearAlgebra, Random

# %% a system
rng = Xoshiro(7)
A = rand(rng, 6, 6) + 6I
b = rand(rng, 6)
x = A \ b

# %% check
norm(A * x - b)

# %% factorizations
F = lu(A)
Q, R = qr(A)
round.(R; digits = 3)

# %% eigenvalues
S = Symmetric(A + A')
eigen(S).values

# %% least squares
t = range(0, 1; length = 50)
y = 2 .+ 3t .+ 0.1randn(rng, 50)
X = [ones(50) t]
coef = X \ y

# %% svd
svdvals(rand(rng, 20, 10))
