# env: base
# kind: interactive
# about: A script that defines many small helpers and calls each a few times.

# %% helpers
for i in 1:150
    name = Symbol(:helper_, i)
    @eval $name(x) = x * $i + $(i % 7) - x ÷ $(1 + i % 5)
end
@eval combine_all(x) = +($([:($(Symbol(:helper_, i))(x)) for i in 1:150]...))

# %% call each
[combine_all(x) for x in 1:3]

# %% via strings
parse_and_apply(s) = getfield(Main, Symbol(:helper_, parse(Int, s)))(10)
sum(parse_and_apply(string(i)) for i in 1:150)
