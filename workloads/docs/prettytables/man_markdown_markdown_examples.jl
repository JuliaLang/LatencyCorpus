# env: data
# kind: interactive
# source: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/docs/src/man/markdown/markdown_examples.md
# license: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/LICENSE.txt

# %% 1
using PrettyTables, Markdown

# %% 2
A = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
    4     true      4.0     0x04
    5    false      5.0     0x05
    6     true      6.0     0x06
]

# %% 3
table = pretty_table(String, A; backend = :markdown)
Markdown.parse(table) # hide

# %% 4
table = pretty_table(
    String,
    A;
    backend = :markdown,
    column_labels = ["ID", "Flag", "Value", "Hex"]
)
Markdown.parse(table) # hide

# %% 5
table = pretty_table(
    String,
    A;
    backend = :markdown,
    style = MarkdownTableStyle(first_line_column_label = MarkdownStyle(bold = true))
)

print(table) # hide

# %% 6
Markdown.parse(table) # hide

# %% 7
table = pretty_table(
    String,
    A;
    backend = :markdown,
    style = MarkdownTableStyle(first_line_column_label = MarkdownStyle(italic = true))
)

print(table) # hide

# %% 8
Markdown.parse(table) # hide

# %% 9
table = pretty_table(
    String,
    A;
    backend = :markdown,
    column_labels = ["Left", "Center", "Right", "Default"],
    alignment = [:l, :c, :r, :r]
)

print(table) # hide

# %% 10
Markdown.parse(table) # hide

# %% 11
data = [
    10.0 6.5
    3.0 3.0
    0.1 1.0
]

row_labels = [
    "Atmospheric drag"
    "Gravity gradient"
    "Solar radiation pressure"
]

column_labels = [
    "Torque [10⁻⁶ Nm]",
    "Angular Momentum [10⁻³ Nms]"
]

table = pretty_table(
    String,
    data;
    backend = :markdown,
    column_labels,
    row_labels,
    stubhead_label = "Effect",
    summary_row_labels = ["Total"],
    summary_rows = [(data, i) -> sum(data[:, i])],
)

print(table) # hide

# %% 12
Markdown.parse(table) # hide

# %% 13
t = 0:1:20

data = hcat(t, ones(length(t)), t, 0.5.*t.^2)

column_labels = [
    ["Time", "Acceleration", "Velocity", "Distance"],
    ["[s]", "[m / s²]", "[m / s]", "[m]"]
]

hl_p = MarkdownHighlighter(
    (data, i, j) -> (j == 4) && (data[i, j] > 9),
    MarkdownStyle(italic = true)
)

hl_v = MarkdownHighlighter(
    (data, i, j) -> (j == 3) && (data[i, j] > 9),
    MarkdownStyle(bold = true)
)

table = pretty_table(
    String,
    data;
    backend = :markdown,
    column_labels = column_labels,
    highlighters = [hl_p, hl_v],
)

print(table) # hide

# %% 14
Markdown.parse(table) # hide
