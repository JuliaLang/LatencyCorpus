# Measuring with the latency corpus

Notes for anyone timing a Julia change with this corpus, agents and people alike. Most of it is
about Julia's object cache, which can make results meaningless without any sign of it.

## The object cache

Julia caches the machine code LLVM produces, keyed by a hash of the unoptimized LLVM module
(see `src/objcache.cpp`). It is on by default and lives in the depot, so it persists across
sessions. A hit skips LLVM's optimization and code generation, but not inference, Julia's
emission of LLVM IR, or hashing the module. `JULIA_OBJCACHE=0` turns it off,
`JULIA_OBJCACHE_PATH` puts it elsewhere, and `JULIA_OBJCACHE_LOG=<file>` writes a line per
lookup saying whether it hit.

That gives two states that really occur, and are worth measuring separately:

- **Cold**: the first time a user does something, and after every Julia upgrade (the key
  includes a hash of the code generator, so a new build starts empty). This is what someone
  trying Julia sees.
- **Warm**: a user repeating a session they ran before. Only what that session compiled before
  is in the cache.

`runner/run.jl` gives each workload an object cache of its own in each mode, empty before its
first repetition and removed after its last. So repetition 1 is cold and repetition 2 warm with
that workload's own output and nothing else. Report the two separately; never average them.

## Rules

- **Never share an object cache between workloads, builds or modes when measuring.** A shared
  cache makes each run warm with whatever ran before it, or alongside it: results then depend
  on the order and concurrency of runs, and differ between builds for reasons unrelated to the
  change, since a build that groups code into modules differently gets different hits.
  `CORPUS_SHARED_OBJCACHE=1` exists for checking that workloads run, not for timing them.
- **Say exactly what was in the cache for every number you report**: none (`JULIA_OBJCACHE=0`),
  empty at the start, or warm with what the same workload compiled before.
- **Compare against a build of master at the change's base**, given as `--master` and run as
  the `master` mode, measured once and reused until master moves. Not the branch with its
  feature turned off: that hides overhead the branch adds elsewhere.
- **Precompile the packages for every build before measuring it** (`runner/install.sh <julia>`).
  Otherwise the first run of each workload also precompiles.
- **Count instructions on a shared machine** (`CORPUS_PERF_LOG=1` records the main thread's
  counters per cell, in `<out>/perf/`). Wall times need `--jobs 1` on a quiet machine. With
  instruction counts, `--jobs N` is fine, since no two runs share a cache.
- **Check that a change does not cost the cache its hits.** Run a workload twice with a cache
  of its own and `JULIA_OBJCACHE_LOG`, for each build, and compare the second runs' misses.
  The second run of master should miss nothing. Anything in emitted code that differs between
  processes defeats the cache for every module that contains it: a pointer emitted as a
  constant (go through a global bound at link time instead, as codegen's `julia_pgv` does), or
  code emitted in the iteration order of a map keyed by pointers.
- **Reproduce a surprising result in a fresh process before believing it**, with nothing but
  the workload's cells, and the cache state it ran with.
- **Judge each class of workload by its own goal** (`runner/summarize.jl`): interactive
  latency, not compiling pointless code (overcompile), and no loss of throughput. Never by
  total wall time across the corpus, which the overcompile workloads dominate.

## Housekeeping

Results (`results/`), the depot and logs stay local. Nothing committed may contain local paths
or other details of the machine it ran on; in particular, printing expressions that contain
macro calls can leave `#= <file>:<line> =#` comments naming the local depot.
