# env: sciml
# kind: unknown
# source: tutorials/linear_analysis.md

# %% 1
using ModelingToolkitStandardLibrary.Blocks, ModelingToolkit
using ModelingToolkit: t_nounits as t

@named P = FirstOrder(k = 1, T = 1) # A first-order system with pole in -1
@named C = Gain(-1)             # A P controller

eqs = [connect(P.output, :plant_output, C.input)  # Connect with an automatically created analysis point called :plant_output
       connect(C.output, :plant_input, P.input)]
sys = System(eqs, t, systems = [P, C], name = :feedback_system)

matrices_S = get_sensitivity(sys, sys.plant_input)[1] # Compute the matrices of a state-space representation of the (input)sensitivity function.
matrices_T = get_comp_sensitivity(sys, sys.plant_input)[1]

# %% 2
using ControlSystemsBase, Plots
S = ss(matrices_S...)
T = ss(matrices_T...)
bodeplot([S, T], lab = ["S" "" "T" ""], plot_title = "Bode plot of sensitivity functions",
    margin = 5Plots.mm)

# %% 3
using ControlSystemsBase
P = tf(1.0, [1, 1]) |> ss
C = 1                      # Negative feedback assumed in ControlSystems
S = sensitivity(P, C)      # or feedback(1, P*C)
T = comp_sensitivity(P, C) # or feedback(P*C)

# %% 4
matrices_L = get_looptransfer(sys, sys.plant_output)[1]
L = ss(matrices_L...)

# %% 5
L = P * (-C) # Add the minus sign to build the negative feedback into the controller

# %% 6
using ModelingToolkit # hide
matrices_PS = linearize(sys, sys.plant_input, sys.plant_output)[1]

# %% 7
feedback(P, C)

# %% 8
tf(S)

# %% 9
margin(P)

# %% 10
nyquistplot(P)
