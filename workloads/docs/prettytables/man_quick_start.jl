# env: data
# kind: interactive
# source: man/quick_start.md

# %% 1
using PrettyTables

# %% 2
data = Any[1 true 1.0; 2 false 2.0; 3 true 3.0];

# %% 3
pretty_table(data)

# %% 4
pretty_table(data; column_labels = ["Index", "Flag", "Value"])

# %% 5
table = (Index = 1:3, Flag = [true, false, true], Value = [1.0, 2.0, 3.0]);

# %% 6
pretty_table(table)

# %% 7
str = pretty_table(String, data; column_labels = ["Index", "Flag", "Value"]);

# %% 8
print(str)

# %% 9
data = [f(a) for a in 0:30:90, f in (sind, cosd, tand)];

# %% 10
highlighter = Highlighter(
    (data, i, j) -> data[i, j] > 1,
    Face(; weight = :bold, foreground = :red)
);

# %% 11
style = TableStyle(; first_line_column_label = Face(; weight = :bold, foreground = :blue));

# %% 12
table_format = TableFormat(; @no_vertical_lines);

# %% 13
pretty_table(
    data;
    column_labels = ["sin", "cos", "tan"],
    formatters    = [fmt__printf("%5.3f")],
    highlighters  = [highlighter],
    row_labels    = ["$(a)°" for a in 0:30:90],
    style,
    table_format,
)

# %% 14
pretty_table(
    data;
    backend       = :markdown,
    column_labels = ["sin", "cos", "tan"],
    formatters    = [fmt__printf("%5.3f")],
    highlighters  = [highlighter],
    row_labels    = ["$(a)°" for a in 0:30:90],
    style,
    table_format,
)

# %% 15
pretty_table(
    data;
    backend       = :latex,
    column_labels = ["sin", "cos", "tan"],
    formatters    = [fmt__printf("%5.3f")],
    highlighters  = [highlighter],
    row_labels    = ["$(a)°" for a in 0:30:90],
    style,
    table_format,
)
