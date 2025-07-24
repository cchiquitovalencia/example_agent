# Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet
# Visualization Functions
# Author: AI Assistant

library(plotly)
library(dplyr)
library(RColorBrewer)

#' Generate solution summary text
#' 
#' @param solution Solution object
#' 
#' @return Formatted solution summary
#' @export
generate_solution_summary <- function(solution) {
  if (is.null(solution) || is.null(solution$routes)) {
    return("No solution available.")
  }
  
  num_routes <- length(solution$routes)
  total_customers_served <- sum(sapply(solution$routes, function(r) {
    sum(r$sequence > max(unique(c(r$depot_id))))  # Count non-depot locations
  }))
  
  total_distance <- sum(sapply(solution$routes, function(r) r$total_distance))
  total_cost <- solution$cost
  
  summary_text <- paste(
    "Solution Summary:",
    paste("- Status:", solution$status),
    paste("- Method:", solution$method),
    paste("- Solve Time:", round(solution$solve_time, 3), "seconds"),
    paste("- Number of Routes:", num_routes),
    paste("- Customers Served:", total_customers_served),
    paste("- Total Distance:", round(total_distance, 2)),
    paste("- Total Cost:", round(total_cost, 2)),
    "",
    "Route Details:",
    sep = "\n"
  )
  
  for (i in 1:length(solution$routes)) {
    route <- solution$routes[[i]]
    summary_text <- paste(summary_text,
      paste("Route", i, "- Vehicle:", route$vehicle_id, 
            "| Distance:", round(route$total_distance, 2),
            "| Load:", route$load,
            "| Time:", round(route$total_time, 2)),
      sep = "\n"
    )
  }
  
  return(summary_text)
}

#' Format routes for display in data table
#' 
#' @param solution Solution object
#' 
#' @return Data frame with formatted route information
#' @export
format_routes_table <- function(solution) {
  if (is.null(solution) || is.null(solution$routes) || length(solution$routes) == 0) {
    return(data.frame())
  }
  
  routes_df <- data.frame()
  
  for (i in 1:length(solution$routes)) {
    route <- solution$routes[[i]]
    
    route_df <- data.frame(
      Route_ID = i,
      Vehicle_ID = route$vehicle_id,
      Depot_ID = route$depot_id,
      Sequence = paste(route$sequence, collapse = " -> "),
      Total_Distance = round(route$total_distance, 2),
      Total_Time = round(route$total_time, 2),
      Load = route$load,
      Customers_Count = sum(route$sequence > route$depot_id) - 1  # Exclude start/end depot
    )
    
    routes_df <- rbind(routes_df, route_df)
  }
  
  return(routes_df)
}

#' Plot routes on a map
#' 
#' @param problem Problem instance
#' @param solution Solution object
#' 
#' @return Plotly visualization of routes
#' @export
plot_routes <- function(problem, solution) {
  if (is.null(problem) || is.null(solution) || is.null(solution$routes)) {
    return(plotly_empty())
  }
  
  # Create base plot with depots and customers
  fig <- plot_ly()
  
  # Add depots
  fig <- fig %>% add_markers(
    x = problem$depots$x, 
    y = problem$depots$y,
    name = "Depots",
    marker = list(color = "red", size = 15, symbol = "square"),
    text = problem$depots$name,
    hovertemplate = "%{text}<br>Position: (%{x}, %{y})<extra></extra>"
  )
  
  # Add customers
  fig <- fig %>% add_markers(
    x = problem$customers$x, 
    y = problem$customers$y,
    name = "Customers",
    marker = list(color = "blue", size = 10, symbol = "circle"),
    text = paste(problem$customers$name, 
                "<br>Demand:", problem$customers$demand,
                "<br>Time Window: [", problem$customers$early_time, 
                ",", problem$customers$late_time, "]"),
    hovertemplate = "%{text}<extra></extra>"
  )
  
  # Add routes
  colors <- brewer.pal(min(max(3, length(solution$routes)), 8), "Set2")
  
  for (i in 1:length(solution$routes)) {
    route <- solution$routes[[i]]
    if (length(route$sequence) <= 2) next  # Skip empty routes
    
    # Get coordinates for the route
    route_x <- c()
    route_y <- c()
    
    for (loc_idx in route$sequence) {
      if (loc_idx <= nrow(problem$depots)) {
        # Depot
        route_x <- c(route_x, problem$depots$x[loc_idx])
        route_y <- c(route_y, problem$depots$y[loc_idx])
      } else {
        # Customer
        customer_idx <- loc_idx - nrow(problem$depots)
        route_x <- c(route_x, problem$customers$x[customer_idx])
        route_y <- c(route_y, problem$customers$y[customer_idx])
      }
    }
    
    # Add route line
    fig <- fig %>% add_trace(
      x = route_x, 
      y = route_y,
      type = "scatter",
      mode = "lines",
      line = list(color = colors[((i-1) %% length(colors)) + 1], width = 3),
      name = paste("Route", i, "- Vehicle", route$vehicle_id),
      hovertemplate = paste("Route", i, "<br>Vehicle:", route$vehicle_id, 
                           "<br>Distance:", round(route$total_distance, 2), 
                           "<extra></extra>")
    )
  }
  
  fig <- fig %>% layout(
    title = "MDVRPTWH Solution Visualization",
    xaxis = list(title = "X Coordinate"),
    yaxis = list(title = "Y Coordinate"),
    showlegend = TRUE,
    hovermode = "closest"
  )
  
  return(fig)
}

#' Plot vehicle utilization
#' 
#' @param solution Solution object
#' 
#' @return Plotly bar chart of vehicle utilization
#' @export
plot_vehicle_utilization <- function(solution) {
  if (is.null(solution) || is.null(solution$routes) || length(solution$routes) == 0) {
    return(plotly_empty())
  }
  
  utilization_data <- data.frame()
  
  for (i in 1:length(solution$routes)) {
    route <- solution$routes[[i]]
    
    # Calculate utilization based on load and capacity
    # Note: capacity info should be available in the route or we need to look it up
    utilization <- data.frame(
      Route = paste("Route", i),
      Vehicle_ID = route$vehicle_id,
      Load = route$load,
      Distance = round(route$total_distance, 2),
      Time = round(route$total_time, 2)
    )
    
    utilization_data <- rbind(utilization_data, utilization)
  }
  
  fig <- plot_ly(utilization_data, 
                 x = ~Route, 
                 y = ~Load, 
                 type = "bar",
                 name = "Load",
                 marker = list(color = "steelblue")) %>%
    layout(
      title = "Vehicle Load Utilization",
      xaxis = list(title = "Route"),
      yaxis = list(title = "Load"),
      showlegend = FALSE
    )
  
  return(fig)
}

#' Plot time windows and service times
#' 
#' @param problem Problem instance
#' @param solution Solution object
#' 
#' @return Plotly gantt-style chart of time windows
#' @export
plot_time_windows <- function(problem, solution) {
  if (is.null(problem) || is.null(solution) || is.null(solution$routes)) {
    return(plotly_empty())
  }
  
  time_data <- data.frame()
  
  # Add customer time windows
  for (i in 1:nrow(problem$customers)) {
    customer <- problem$customers[i, ]
    time_data <- rbind(time_data, data.frame(
      Entity = paste("Customer", i),
      Type = "Time Window",
      Start = customer$early_time,
      End = customer$late_time,
      Color = "lightblue"
    ))
  }
  
  # Add actual service times from solution
  for (route in solution$routes) {
    for (j in 2:(length(route$sequence) - 1)) {  # Skip depot start/end
      loc_idx <- route$sequence[j]
      if (loc_idx > nrow(problem$depots)) {
        customer_idx <- loc_idx - nrow(problem$depots)
        service_time <- route$service_times[j]
        customer <- problem$customers[customer_idx, ]
        
        time_data <- rbind(time_data, data.frame(
          Entity = paste("Customer", customer_idx),
          Type = "Service Time",
          Start = service_time,
          End = service_time + customer$service_time,
          Color = "red"
        ))
      }
    }
  }
  
  if (nrow(time_data) == 0) {
    return(plotly_empty())
  }
  
  # Create gantt-style plot
  fig <- plot_ly()
  
  # Add time windows
  time_windows <- time_data[time_data$Type == "Time Window", ]
  if (nrow(time_windows) > 0) {
    fig <- fig %>% add_trace(
      x = time_windows$Start,
      y = time_windows$Entity,
      xend = time_windows$End,
      yend = time_windows$Entity,
      type = "scatter",
      mode = "lines",
      line = list(color = "lightblue", width = 10),
      name = "Time Windows",
      hovertemplate = "%{y}<br>Window: [%{x}, %{xend}]<extra></extra>"
    )
  }
  
  # Add service times
  service_times <- time_data[time_data$Type == "Service Time", ]
  if (nrow(service_times) > 0) {
    fig <- fig %>% add_trace(
      x = service_times$Start,
      y = service_times$Entity,
      xend = service_times$End,
      yend = service_times$Entity,
      type = "scatter",
      mode = "lines",
      line = list(color = "red", width = 5),
      name = "Service Times",
      hovertemplate = "%{y}<br>Service: [%{x}, %{xend}]<extra></extra>"
    )
  }
  
  fig <- fig %>% layout(
    title = "Time Windows and Service Times",
    xaxis = list(title = "Time"),
    yaxis = list(title = "Customer"),
    showlegend = TRUE
  )
  
  return(fig)
}