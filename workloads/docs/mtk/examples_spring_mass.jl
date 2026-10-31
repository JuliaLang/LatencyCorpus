# env: sciml
# kind: overcompile
# source: examples/spring_mass.md

# %% 1
using ModelingToolkit, Plots, OrdinaryDiffEq, LinearAlgebra
using ModelingToolkit: t_nounits as t, D_nounits as D
using Symbolics: scalarize

function Mass(; name, m = 1.0, xy = [0.0, 0.0], u = [0.0, 0.0])
    ps = @parameters m = m
    sts = @variables pos(t)[1:2]=xy v(t)[1:2]=u
    eqs = scalarize(D.(pos) .~ v)
    System(eqs, t, [pos..., v...], ps; name)
end

function Spring(; name, k = 1e4, l = 1.0)
    ps = @parameters k=k l=l
    @variables x(t), dir(t)[1:2]
    System(Equation[], t, [x, dir...], ps; name)
end

function connect_spring(spring, a, b)
    [spring.x ~ norm(scalarize(a .- b))
     scalarize(spring.dir .~ scalarize(a .- b))]
end

function spring_force(spring)
    -spring.k .* scalarize(spring.dir) .* (spring.x - spring.l) ./ spring.x
end

m = 1.0
xy = [1.0, -1.0]
k = 1e4
l = 1.0
center = [0.0, 0.0]
g = [0.0, -9.81]
@named mass = Mass(m = m, xy = xy)
@named spring = Spring(k = k, l = l)

eqs = [connect_spring(spring, mass.pos, center)
       scalarize(D.(mass.v) .~ spring_force(spring) / mass.m .+ g)]

@named _model = System(eqs, t, [spring.x; spring.dir; mass.pos], [])
@named model = compose(_model, mass, spring)
sys = mtkcompile(model)

prob = ODEProblem(sys, [], (0.0, 3.0))
sol = solve(prob, Rosenbrock23())
plot(sol)

# %% 2
function Mass(; name, m = 1.0, xy = [0.0, 0.0], u = [0.0, 0.0])
    ps = @parameters m = m
    sts = @variables pos(t)[1:2]=xy v(t)[1:2]=u
    eqs = scalarize(D.(pos) .~ v)
    System(eqs, t, [pos..., v...], ps; name)
end

# %% 3
Mass(name = :mass1)

# %% 4
@named mass1 = Mass()

# %% 5
function Spring(; name, k = 1e4, l = 1.0)
    ps = @parameters k=k l=l
    @variables x(t), dir(t)[1:2]
    System(Equation[], t, [x, dir...], ps; name)
end

# %% 6
function connect_spring(spring, a, b)
    [spring.x ~ norm(scalarize(a .- b))
     scalarize(spring.dir .~ scalarize(a .- b))]
end

# %% 7
function spring_force(spring)
    -spring.k .* scalarize(spring.dir) .* (spring.x - spring.l) ./ spring.x
end

# %% 8
m = 1.0
xy = [1.0, -1.0]
k = 1e4
l = 1.0
center = [0.0, 0.0]
g = [0.0, -9.81]
@named mass = Mass(m = m, xy = xy)
@named spring = Spring(k = k, l = l)

# %% 9
eqs = [connect_spring(spring, mass.pos, center)
       scalarize(D.(mass.v) .~ spring_force(spring) / mass.m .+ g)]

# %% 10
@named _model = System(eqs, t, [spring.x; spring.dir; mass.pos], [])
@named model = compose(_model, mass, spring)

# %% 11
equations(model)

# %% 12
unknowns(model)

# %% 13
parameters(model)

# %% 14
sys = mtkcompile(model)
equations(sys)

# %% 15
full_equations(sys)

# %% 16
prob = ODEProblem(sys, [], (0.0, 3.0))
sol = solve(prob, Rosenbrock23())
plot(sol)

# %% 17
observed(sys)

# %% 18
sol[mass.pos[1]]

# %% 19
plot(sol, idxs = (mass.pos[1], mass.pos[2]))
