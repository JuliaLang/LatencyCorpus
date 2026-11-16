#!/bin/bash
# Install the corpus environments from their manifests into the corpus's own depot, and
# precompile them with the Julia to be measured:
#
#     runner/install.sh <julia> [env...]
#
# With no environments named, installs all of them. Precompiled packages are specific to
# the Julia build, so run this again with each build to be measured before measuring it:
# otherwise the first run of each workload also precompiles.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
julia=$1
shift
envs=("$@")
[ ${#envs[@]} -eq 0 ] && envs=($(ls "$root/envs"))
export JULIA_DEPOT_PATH=$root/depot JULIA_PKG_PRECOMPILE_AUTO=0
mkdir -p "$root/logs"
for env in "${envs[@]}"; do
    start=$(date +%s)
    "$julia" --startup-file=no --project="$root/envs/$env" \
        -e "using Pkg; Pkg.instantiate(); Pkg.precompile(; timing=true)" > "$root/logs/install-$env.log" 2>&1
    echo "$env: exit $? in $(( $(date +%s) - start ))s (log in logs/install-$env.log)"
done
