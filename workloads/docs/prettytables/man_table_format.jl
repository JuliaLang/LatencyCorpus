# env: data
# kind: interactive
# source: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/docs/src/man/table_format.md
# license: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/LICENSE.txt

# %% 1
using PrettyTables

# %% 2
matrix = [1 2 3; 4 5 6; 7 8 9];

# %% 3
table_format = TableFormat(;
    horizontal_lines_at_data_rows = :all,
    vertical_lines_at_data_columns = :none,
    header_line = LineStyle(; style = :double),
);

# %% 4
style = TableStyle(;
    title = Face(; weight = :bold, foreground = :magenta),
    first_line_column_label = Face(; slant = :italic, foreground = :blue),
);

# %% 5
pretty_table(matrix; style, table_format, title = "Title")

# %% 6
pretty_table(matrix; backend = :latex, style, table_format, title = "Title")

# %% 7
pretty_table(matrix; backend = :typst, style, table_format, title = "Title")

# %% 8
pretty_table([1 2; 3 4]; table_format = TableFormat(horizontal_lines_at_data_rows = :all))

# %% 9
pretty_table(
    [1 2; 3 4];
    table_format = TableFormat(;
        @no_horizontal_lines,
        @all_vertical_lines,
        horizontal_line_after_column_labels = true,
    )
)

# %% 10
table_format = TableFormat(;
    @no_vertical_lines,
    horizontal_lines_at_data_rows = :all,
    top_line    = LineStyle(; width = :thick),
    header_line = LineStyle(; style = :double, color = :blue),
    middle_line = LineStyle(; style = :dashed),
    bottom_line = LineStyle(; width = :thick),
);

# %% 11
pretty_table(matrix; table_format)

# %% 12
pretty_table(matrix; backend = :typst, table_format)

# %% 13
html_line_style(LineStyle(; style = :dashed, width = :thick, color = :red))

# %% 14
typst_line_style(LineStyle(; style = :dashed, width = :thick, color = :red))

# %% 15
excel_line_style(LineStyle(; style = :dashed, color = 0xff0000))

# %% 16
docx_line_style(LineStyle(; style = :double, width = :medium, color = :blue))

# %% 17
latex_line_style(LineStyle(; style = :double))

# %% 18
style = TableStyle(; first_line_column_label = Face(; slant = :italic, foreground = :blue));

# %% 19
pretty_table([1 2; 3 4]; style = style)
