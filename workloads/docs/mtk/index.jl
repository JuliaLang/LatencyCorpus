# env: sciml
# kind: overcompile
# source: index.md

# %% 1
using Pkg # hide
Pkg.status() # hide

# %% 2
using InteractiveUtils # hide
versioninfo() # hide

# %% 3
using Pkg # hide
Pkg.status(; mode = PKGMODE_MANIFEST) # hide
