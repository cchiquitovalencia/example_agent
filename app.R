# Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet
# Shiny Application
# Author: AI Assistant
# Date: 2024

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)

# Source supporting files
source("R/problem_definition.R")
source("R/solver.R")
source("R/visualization.R")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "MDVRPTWH Solver"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Problem Setup", tabName = "setup", icon = icon("cog")),
      menuItem("Solution", tabName = "solution", icon = icon("route")),
      menuItem("Visualization", tabName = "visualization", icon = icon("chart-line")),
      menuItem("Documentation", tabName = "docs", icon = icon("book"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Problem Setup Tab
      tabItem(tabName = "setup",
        fluidRow(
          box(title = "Problem Parameters", status = "primary", solidHeader = TRUE, width = 6,
            numericInput("num_depots", "Number of Depots:", value = 2, min = 1, max = 5),
            numericInput("num_customers", "Number of Customers:", value = 7, min = 1, max = 20),
            numericInput("num_vehicles", "Number of Vehicles:", value = 2, min = 1, max = 10),
            numericInput("num_vehicle_types", "Number of Vehicle Types:", value = 2, min = 1, max = 5),
            actionButton("generate_problem", "Generate Problem Instance", class = "btn-primary")
          ),
          box(title = "Problem Instance", status = "info", solidHeader = TRUE, width = 6,
            verbatimTextOutput("problem_summary")
          )
        ),
        fluidRow(
          box(title = "Depots", status = "success", solidHeader = TRUE, width = 6,
            DT::dataTableOutput("depots_table")
          ),
          box(title = "Customers", status = "success", solidHeader = TRUE, width = 6,
            DT::dataTableOutput("customers_table")
          )
        ),
        fluidRow(
          box(title = "Vehicles", status = "warning", solidHeader = TRUE, width = 12,
            DT::dataTableOutput("vehicles_table")
          )
        )
      ),
      
      # Solution Tab
      tabItem(tabName = "solution",
        fluidRow(
          box(title = "Solver Controls", status = "primary", solidHeader = TRUE, width = 4,
            selectInput("solver_method", "Solver Method:", 
                       choices = c("Nearest Neighbor" = "nn", 
                                 "Greedy" = "greedy",
                                 "Simulated Annealing" = "sa")),
            numericInput("max_iterations", "Max Iterations:", value = 1000, min = 100, max = 10000),
            actionButton("solve_problem", "Solve Problem", class = "btn-success"),
            br(), br(),
            verbatimTextOutput("solution_status")
          ),
          box(title = "Solution Summary", status = "info", solidHeader = TRUE, width = 8,
            verbatimTextOutput("solution_summary")
          )
        ),
        fluidRow(
          box(title = "Routes", status = "success", solidHeader = TRUE, width = 12,
            DT::dataTableOutput("routes_table")
          )
        )
      ),
      
      # Visualization Tab
      tabItem(tabName = "visualization",
        fluidRow(
          box(title = "Route Visualization", status = "primary", solidHeader = TRUE, width = 12,
            plotlyOutput("route_plot", height = "600px")
          )
        ),
        fluidRow(
          box(title = "Vehicle Utilization", status = "info", solidHeader = TRUE, width = 6,
            plotlyOutput("utilization_plot")
          ),
          box(title = "Time Windows", status = "warning", solidHeader = TRUE, width = 6,
            plotlyOutput("time_windows_plot")
          )
        )
      ),
      
      # Documentation Tab
      tabItem(tabName = "docs",
        fluidRow(
          box(title = "Problem Description", status = "primary", solidHeader = TRUE, width = 12,
            includeMarkdown("docs/problem_description.md")
          )
        ),
        fluidRow(
          box(title = "Algorithm Documentation", status = "info", solidHeader = TRUE, width = 6,
            includeMarkdown("docs/algorithms.md")
          ),
          box(title = "API Reference", status = "success", solidHeader = TRUE, width = 6,
            includeMarkdown("docs/api_reference.md")
          )
        )
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive values to store problem instance and solution
  values <- reactiveValues(
    problem = NULL,
    solution = NULL
  )
  
  # Generate problem instance
  observeEvent(input$generate_problem, {
    values$problem <- generate_problem_instance(
      num_depots = input$num_depots,
      num_customers = input$num_customers,
      num_vehicles = input$num_vehicles,
      num_vehicle_types = input$num_vehicle_types
    )
    
    showNotification("Problem instance generated successfully!", type = "success")
  })
  
  # Solve problem
  observeEvent(input$solve_problem, {
    req(values$problem)
    
    withProgress(message = "Solving problem...", value = 0, {
      values$solution <- solve_mdvrptwh(
        problem = values$problem,
        method = input$solver_method,
        max_iterations = input$max_iterations
      )
      setProgress(1)
    })
    
    showNotification("Problem solved successfully!", type = "success")
  })
  
  # Problem summary
  output$problem_summary <- renderText({
    if (is.null(values$problem)) {
      "No problem instance generated yet. Click 'Generate Problem Instance' to start."
    } else {
      generate_problem_summary(values$problem)
    }
  })
  
  # Data tables
  output$depots_table <- DT::renderDataTable({
    if (!is.null(values$problem)) {
      values$problem$depots
    }
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  output$customers_table <- DT::renderDataTable({
    if (!is.null(values$problem)) {
      values$problem$customers
    }
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  output$vehicles_table <- DT::renderDataTable({
    if (!is.null(values$problem)) {
      values$problem$vehicles
    }
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  output$routes_table <- DT::renderDataTable({
    if (!is.null(values$solution)) {
      format_routes_table(values$solution)
    }
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  # Solution outputs
  output$solution_status <- renderText({
    if (is.null(values$solution)) {
      "No solution available. Generate a problem instance and solve it."
    } else {
      paste("Status:", values$solution$status)
    }
  })
  
  output$solution_summary <- renderText({
    if (!is.null(values$solution)) {
      generate_solution_summary(values$solution)
    }
  })
  
  # Visualizations
  output$route_plot <- renderPlotly({
    if (!is.null(values$problem) && !is.null(values$solution)) {
      plot_routes(values$problem, values$solution)
    }
  })
  
  output$utilization_plot <- renderPlotly({
    if (!is.null(values$solution)) {
      plot_vehicle_utilization(values$solution)
    }
  })
  
  output$time_windows_plot <- renderPlotly({
    if (!is.null(values$problem) && !is.null(values$solution)) {
      plot_time_windows(values$problem, values$solution)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)