# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/index.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using Pkg # hide
Pkg.status() # hide

# %% 2
using InteractiveUtils # hide
versioninfo() # hide

# %% 3
using Pkg # hide
Pkg.status(; mode = PKGMODE_MANIFEST) # hide
