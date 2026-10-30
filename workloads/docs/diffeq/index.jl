# env: sciml
# kind: unknown
# source: index.md

# %% 1
import Pkg # hide
Pkg.status() # hide

# %% 2
import InteractiveUtils # hide
InteractiveUtils.versioninfo() # hide

# %% 3
import Pkg # hide
Pkg.status(; mode = Pkg.PKGMODE_MANIFEST) # hide
