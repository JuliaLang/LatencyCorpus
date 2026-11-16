# env: data
# kind: interactive
# source: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/docs/src/man/html/html_examples.md
# license: https://github.com/ronisbr/PrettyTables.jl/blob/v3.5.0/LICENSE.txt

# %% 1
using PrettyTables

function pt_to_html(args...; kwargs...)
    str = pretty_table(String, args...; kwargs...)
    return Base.HTML(str)
end

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
pt_to_html(         # hide
    A;              # hide
    backend = :html # hide
)                   # hide

# %% 4
pt_to_html(                                                                         # hide
    A;                                                                              # hide
    backend = :html,                                                                # hide
    style = HtmlTableStyle(;                                                        # hide
        first_line_column_label = ["color" => "BurlyWood", "font-weight" => "bold"] # hide
    )                                                                               # hide
)                                                                                   # hide

# %% 5
data = [                                                                                    # hide
    10.0 6.5                                                                                # hide
     3.0 3.0                                                                                # hide
     0.1 1.0                                                                                # hide
]                                                                                           # hide
                                                                                            # hide
row_labels = [                                                                              # hide
    "Atmospheric drag"                                                                      # hide
    "Gravity gradient"                                                                      # hide
    "Solar radiation pressure"                                                              # hide
]                                                                                           # hide
                                                                                            # hide
column_labels = [                                                                           # hide
    [MultiColumn(2, "Value", :c)],                                                          # hide
    [                                                                                       # hide
        "Torque [10⁻⁶ Nm]",                                                                 # hide
        "Angular Momentum [10⁻³ Nms]"                                                       # hide
    ]                                                                                       # hide
]                                                                                           # hide
                                                                                            # hide
pt_to_html(                                                                                 # hide
    data;                                                                                   # hide
    backend = :html,                                                                        # hide
    column_labels,                                                                          # hide
    merge_column_label_cells = :auto,                                                       # hide
    row_labels,                                                                             # hide
    stubhead_label = "Effect",                                                              # hide
    style = HtmlTableStyle(;                                                                # hide
        first_line_merged_column_label = ["color" => "BurlyWood", "font-weight" => "bold"], # hide
        column_label                   = ["color" => "DarkGrey"],                           # hide
        stubhead_label                 = ["color" => "BurlyWood", "font-weight" => "bold"], # hide
        summary_row_label              = ["color" => "red",       "font-weight" => "bold"]  # hide
    ),                                                                                      # hide
    summary_row_labels = ["Total"],                                                         # hide
    summary_rows = [(data, i) -> sum(data[:, i])],                                          # hide
)                                                                                           # hide

# %% 6
t = 0:1:20                                                                           # hide
                                                                                     # hide
data = hcat(t, ones(length(t) ), t, 0.5.*t.^2);                                      # hide
                                                                                     # hide
column_labels = [                                                                    # hide
    ["Time", "Acceleration", "Velocity", "Distance"],                                # hide
    [ "[s]",     "[m / s²]",  "[m / s]",      "[m]"]                                 # hide
]                                                                                    # hide
                                                                                     # hide
hl_p = HtmlHighlighter(                                                              # hide
    (data, i, j) -> (j == 4) && (data[i, j] > 9),                                    # hide
    ["color" => "blue"]                                                              # hide
)                                                                                    # hide
                                                                                     # hide
hl_v = HtmlHighlighter(                                                              # hide
    (data, i, j) -> (j == 3) && (data[i, j] > 9),                                    # hide
    ["color" => "red"]                                                               # hide
)                                                                                    # hide
                                                                                     # hide
pt_to_html(                                                                          # hide
    data;                                                                            # hide
    backend = :html,                                                                 # hide
    column_labels = column_labels,                                                   # hide
    highlighters  = [hl_p, hl_v],                                                    # hide
    style = HtmlTableStyle(;                                                         # hide
        first_line_column_label = ["color" => "BurlyWood", "font-weight" => "bold"], # hide
        column_label            = ["color" => "DarkGrey"],                           # hide
    )                                                                                # hide
)                                                                                    # hide
