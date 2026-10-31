# env: data
# kind: interactive
# source: man/text/text_backend.md

# %% 1
using PrettyTables

# %% 2
hl_gt5 = TextHighlighter(
    (data, i, j) -> data[i, j] > 5,
    Face(; weight = :bold, foreground = :red)
);

# %% 3
hl_lt5 = TextHighlighter((data, i, j) -> data[i, j] < 5; foreground = :blue);

# %% 4
pretty_table([1 10; 5 7]; highlighters = [hl_gt5, hl_lt5])

# %% 5
pretty_table(
    [1 2; 3 4];
    table_format = TextTableFormat(;
        header_line = TextTableLine(;
            left_intersection   = '╞',
            middle_intersection = '╪',
            right_intersection  = '╡',
            row                 = '═',
        ),
        center_line = '┊',
    )
)

# %% 6
style = TextTableStyle(;
    stubhead_label = Face(; weight = :bold, foreground = :red),
    table_border   = Face(; foreground = :bright_black),
);

# %% 7
pretty_table([1 2; 3 4]; row_labels = ["A", "B"], stubhead_label = "Label", style)
