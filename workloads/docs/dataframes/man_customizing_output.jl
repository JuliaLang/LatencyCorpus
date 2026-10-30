# env: data
# kind: unknown
# source: man/customizing_output.md

# %% 1
using DataFrames

# %% 2
df = DataFrame(
    a = [1, 2, 3],
    b = [3.14, -1.2, 42.0],
    c = ["short", "a very very very very very long string", "ok"]
);

# %% 3
# This is the default output.

# %% 4
df

# %% 5
# Using this option, no cell will be truncated if there is room to display it.

# %% 6
show(df; truncate = 0)

# %% 7
# Hide row numbers.

# %% 8
show(df; show_row_number = false)

# %% 9
# Hide the column element types in text output.

# %% 10
show(df; eltypes = false)

# %% 11
using PrettyTables

# %% 12
df = DataFrame(
    A = [ 0.73, -1.28,  1.91, -0.44,  0.12, -2.35,  1.08],
    B = [-0.55,  0.67, -1.49,  2.11, -0.03,  0.94, -2.20],
    C = [ 1.34, -0.88,  0.45, -1.76,  2.53, -0.61,  0.07],
    D = [-1.02,  2.40, -0.31,  0.58, -2.14,  1.77, -0.90],
    E = [ 0.26, -1.67,  2.22, -0.75,  1.05, -0.48, -2.93]
);

# %% 13
# This is the default output.

# %% 14
df

# %% 15
function parentheses_fmt(v, i, j)
    !(v isa Number) && return v
    v < 0 && return "($(-v))"
    return v
end;

# %% 16
show(df; formatters = [parentheses_fmt])

# %% 17
using Statistics, PrettyTables

# %% 18
profit = DataFrame(
    "2020" => [ 94.6, -105.6, -104.9,  -88.0],
    "2021" => [-84.3,   -8.7, -109.6,   75.8],
    "2022" => [172.6,  -42.5,   95.5, -141.0],
    "2023" => [-71.2,   51.6,  114.3,   15.5],
    "2024" => [-35.4,  -44.9,  140.3,   30.8],
    "2025" => [ 24.1,  136.1,   34.8, -183.7]
);

# %% 19
show(
    profit;
    # We use this option to align the summary rows with the data rows at the decimal
    # point.
    apply_alignment_regex_to_summary_rows = true,
    summary_rows = [mean, std],
    summary_row_labels = ["Mean", "Std. Dev."]
)
