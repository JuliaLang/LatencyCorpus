# env: base
# kind: interactive
# mode: script
# about: Puzzle-style script: parse a grid, find shortest paths with BFS and Dijkstra.

# %% input
using Random
rng = Xoshiro(2)
n = 300
input = join([join(rand(rng) < 0.25 ? '#' : rand(rng, '1':'9') for _ in 1:n) for _ in 1:n], '\n');

# %% parse
lines = split(input, '\n')
grid = permutedims(reduce(hcat, [collect(l) for l in lines]))
size(grid)

# %% bfs
function bfs(grid, start, goal)
    dist = fill(-1, size(grid))
    dist[start] = 0
    queue = [start]
    head = 1
    while head <= length(queue)
        p = queue[head]; head += 1
        p == goal && return dist[p]
        for d in (CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1))
            q = p + d
            checkbounds(Bool, grid, q) || continue
            grid[q] == '#' && continue
            dist[q] == -1 || continue
            dist[q] = dist[p] + 1
            push!(queue, q)
        end
    end
    return -1
end
grid[1, 1] = grid[end, end] = '1'
bfs(grid, CartesianIndex(1, 1), CartesianIndex(n, n))

# %% dijkstra
function dijkstra(grid, start, goal)
    cost = fill(typemax(Int), size(grid))
    cost[start] = 0
    frontier = Dict(start => 0)
    while !isempty(frontier)
        p, c = first(sort!(collect(frontier); by=last))
        delete!(frontier, p)
        p == goal && return c
        for d in (CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1))
            q = p + d
            checkbounds(Bool, grid, q) && grid[q] != '#' || continue
            nc = c + (grid[q] - '0')
            if nc < cost[q]
                cost[q] = nc
                frontier[q] = nc
            end
        end
    end
    return -1
end
dijkstra(grid[1:60, 1:60], CartesianIndex(1, 1), CartesianIndex(60, 60))
