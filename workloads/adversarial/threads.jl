# env: base
# kind: throughput
# args: --threads=4
# about: Threaded loops and tasks: interpreted and compiled code run on several threads.

# %% threads
using Base.Threads
nthreads()

# %% threaded loop
function threaded_sum(n)
    acc = zeros(maxthreadid() * 8)
    @threads :static for i in 1:n
        acc[threadid()*8] += sin(i)^2
    end
    return sum(acc)
end
threaded_sum(40_000_000)

# %% spawn
function fib(n)
    n < 25 && return n < 2 ? n : fib(n - 1) + fib(n - 2)
    t = @spawn fib(n - 2)
    return fib(n - 1) + fetch(t)
end
fib(34)

# %% channels
ch = Channel{Int}(100)
producer = @spawn begin
    for i in 1:200_000
        put!(ch, i)
    end
    close(ch)
end
sum(ch)
