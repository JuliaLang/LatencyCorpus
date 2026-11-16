# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/index.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import Pkg # hide
Pkg.status() # hide

# %% 2
import InteractiveUtils # hide
InteractiveUtils.versioninfo() # hide

# %% 3
import Pkg # hide
Pkg.status(; mode = Pkg.PKGMODE_MANIFEST) # hide
