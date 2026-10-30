#!/bin/bash
# Install one corpus environment: install.sh <env> <julia expr adding packages>
set -u
root=$HOME/dev/latency-corpus
export JULIA_DEPOT_PATH=$root/depot JULIA_PKG_SERVER_REGISTRY_PREFERENCE=eager JULIA_PKG_PRECOMPILE_AUTO=0
mkdir -p $root/envs/$1
start=$(date +%s)
timeout 3600 $HOME/dev/julia/usr/bin/julia --startup-file=no --project=$root/envs/$1 \
  -e "using Pkg; $2; Pkg.precompile(; timing=true); Pkg.status()" > $root/logs/install-$1.log 2>&1
echo "INSTALL $1 EXIT $? $(( $(date +%s) - start ))s" >> $root/logs/install-$1.log
