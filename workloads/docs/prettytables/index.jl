# env: data
# kind: interactive
# source: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/docs/src/index.md
# license: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/LICENSE.txt

# %% 1
using PrettyTables

# %% 2
# == Creating the Table ====================================================================

v1_t = 0:5:20
v1_a = ones(length(v1_t)) * 1.0
v1_v = @. 0 + v1_a * v1_t
v1_d = @. 0 + v1_a * v1_t^2 / 2

v2_t = 0:5:20
v2_a = ones(length(v2_t)) * 0.75
v2_v = @. 0 + v2_a * v2_t
v2_d = @. 0 + v2_a * v2_t^2 / 2

table = [
    v1_t v1_a v1_v v1_d
    v2_t v2_a v2_v v2_d
]

# == Configuring the Table =================================================================

title = "Table 1. Data obtained from the test procedure."

subtitle = "Comparison between two vehicles"

column_labels = [
    [EmptyCells(2), MultiColumn(2, "Estimated Data")],
    ["Time (s)", "Acceleration", "Velocity", "Position"],
    [
        styled"{(foreground=gray):[s]}",
        styled"{(foreground=gray):[m / s²]}",
        styled"{(foreground=gray):[m / s]}",
        styled"{(foreground=gray):[m]}",
    ],
]

row_group_labels = [
    1 => "Vehicle #1",
    6 => "Vehicle #2"
]

summary_rows = [
    (data, j) -> maximum(@views data[ 1:5, j]),
    (data, j) -> maximum(@views data[6:10, j]),
]

summary_row_labels = [
    "Max. for Vehicle #1",
    "Max. for Vehicle #2",
]

footnotes = [
    (:column_label, 1, 3) => "Estimated data based on the acceleration measurement."
]

highlighters = [
    Highlighter(
        (data, i, j) -> (j == 3) && (data[i, j] > 10),
        Face(; weight = :bold, foreground = :red)
    ),
    Highlighter(
        (data, i, j) -> (j == 4) && (data[i, j] > 10),
        Face(; weight = :bold, foreground = :blue)
    ),
]

table_format = TableFormat(; @no_vertical_lines)

style = TableStyle(;
    column_label                   = Face(; weight = :bold),
    first_line_merged_column_label = Face(;
        weight = :bold, foreground = :yellow, underline = true
    ),
    footnote                       = Face(; foreground = :cyan),
    row_group_label                = Face(; weight = :bold, foreground = :magenta),
    subtitle                       = Face(; slant = :italic),
    title                          = Face(; weight = :bold, foreground = :yellow),
)

nothing # hide

# %% 3
pretty_table(
    HTML,
    table;
    column_labels,
    footnotes,
    highlighters,
    row_group_labels,
    style,
    subtitle,
    summary_row_labels,
    summary_rows,
    table_format,
    title,
)
