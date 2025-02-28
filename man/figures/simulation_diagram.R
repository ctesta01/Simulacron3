library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

grViz("
digraph simulation_workflow {

  # Set left-to-right orientation
  graph [rankdir = LR]

  # Node definitions with styles
  node [shape = rectangle, style = 'rounded, filled', fillcolor = 'LightSteelBlue',
        fontname = 'Futura', alpha = 0.8, fontsize=8, width=2]
  sim [label = 'Simulation (sim)']
  dgp [label = 'Data Generating Process (dgp)']
  estimators [label = 'Estimators']
  configuration [label = 'Config (iterations, sample sizes, etc.)']
  summary_stats [label = 'Summary Statistics']

  # Edges connecting nodes
  dgp -> sim
  estimators -> sim
  configuration -> sim
  sim -> summary_stats
}
") -> graph

# export to png and pdf
graph %>%
  export_svg %>% charToRaw %>% rsvg_pdf("simulation_diagram.pdf")
graph %>%
  export_svg %>% charToRaw %>% rsvg_png(file = "simulation_diagram.png", width = 1000, height = 500)


# render graphic to screen
graph
