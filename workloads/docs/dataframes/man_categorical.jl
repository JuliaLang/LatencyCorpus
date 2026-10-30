# env: data
# kind: unknown
# source: man/categorical.md

# %% 1
v = ["Group A", "Group A", "Group A", "Group B", "Group B", "Group B"]

# %% 2
using CategoricalArrays

# %% 3
cv = categorical(v)

# %% 4
cv = categorical(["Group A", missing, "Group A",
                  "Group B", "Group B", missing])

# %% 5
levels(cv)

# %% 6
levels!(cv, ["Group B", "Group A"])

# %% 7
levels(cv)

# %% 8
sort(cv)

# %% 9
cv = compress(cv)

# %% 10
cv1 = categorical(["A", "B"], compress=true)

# %% 11
cv2 = categorical(["A", "B"], ordered=true)

# %% 12
# pruned: failed without tiering
# %% 13
cv2[1] < cv2[2]

# %% 14
isordered(cv1)

# %% 15
ordered!(cv1, true)

# %% 16
isordered(cv1)

# %% 17
cv1[1] < cv1[2]
