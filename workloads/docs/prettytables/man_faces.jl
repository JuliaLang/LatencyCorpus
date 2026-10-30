# env: data
# kind: unknown
# source: man/faces.md

# %% 1
using PrettyTables

# %% 2
style = TableStyle(;
    title = Face(; weight = :bold, foreground = :magenta),
    first_line_column_label = Face(; weight = :bold, foreground = :blue),
);

# %% 3
pretty_table([1 2; 3 4]; style, title = "Title")

# %% 4
pretty_table([1 2; 3 4]; backend = :latex, style, title = "Title")

# %% 5
pretty_table(HTML, [1 2; 3 4]; style, title = "Title")

# %% 6
style = TextTableStyle(; table_border = Face(; foreground = :yellow));

# %% 7
pretty_table([1 2; 3 4]; style)

# %% 8
style = HtmlTableStyle(; title = Face(; weight = :bold, foreground = :red));

# %% 9
style.title

# %% 10
hl = Highlighter((data, i, j) -> data[i, j] > 5, Face(; weight = :bold, foreground = :red));

# %% 11
pretty_table([1 10; 3 7]; highlighters = [hl])

# %% 12
pretty_table([1 10; 3 7]; backend = :latex, highlighters = [hl])

# %% 13
face = Face(; weight = :bold, slant = :italic, foreground = :red, background = "#00ff00", underline = true, strikethrough = true);

# %% 14
html_decoration(face)

# %% 15
latex_decoration(face)

# %% 16
markdown_decoration(face)

# %% 17
typst_decoration(face)

# %% 18
excel_decoration(face)

# %% 19
docx_decoration(face)

# %% 20
matrix = [styled"{bold:Bold} and {red:red}" styled"{(fg=blue),italic:Blue italics}"];

# %% 21
pretty_table(matrix)

# %% 22
pretty_table(matrix; backend = :markdown)

# %% 23
pretty_table(matrix; backend = :latex)
