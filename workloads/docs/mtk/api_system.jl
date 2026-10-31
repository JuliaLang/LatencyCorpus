# env: sciml
# kind: overcompile
# source: API/System.md

# %% 1
using ModelingToolkit
using ModelingToolkitStandardLibrary.Blocks
using ModelingToolkit: t_nounits as t

@named plant = FirstOrder(k = 1, T = 1)
@named controller = Gain(k = -1)
eqs = [
    connect(controller.output, :plant_input, plant.input)
    connect(plant.output, :plant_output, controller.input)
]
@named closed_loop = System(eqs, t, systems = [plant, controller])

isolated, input_vars, output_vars =
    isolate_subsystem(closed_loop, closed_loop.plant_input, closed_loop.plant_output)
isequal(only(input_vars), plant.input.u), isequal(only(output_vars), plant.output.u)
