# env: data
# kind: unknown
# source: man/text/predefined_formats.md

# %% 1
using PrettyTables

# %% 2
data = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
];

# %% 3
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__ascii_dots)
)

# %% 4
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__ascii_rounded)
)

# %% 5
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__borderless)
)

# %% 6
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__compact)
)

# %% 7
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__matrix)
)

# %% 8
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__mysql)
)

# %% 9
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__simple)
)

# %% 10
pretty_table(
  data;
  backend = :text,
  table_format = TextTableFormat(borders = text_table_borders__unicode_rounded)
)

# %% 11
pretty_table(
  ones(3, 3);
  backend = :text,
  show_column_labels = false,
  table_format = text_table_format__matrix
)
