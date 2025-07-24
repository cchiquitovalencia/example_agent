# 2-opt Local Search Improvement Heuristic for Vehicle Routing Problem (VRP)
#
# This improvement heuristic takes an existing VRP solution and applies 2-opt
# moves to improve individual routes by removing two edges and reconnecting
# the route in a different way.

# Function to calculate Euclidean distance between two points
euclidean_distance <- function(point1, point2) {
  sqrt((point1[1] - point2[1])^2 + (point1[2] - point2[2])^2)
}

# Function to compute distance matrix
compute_distance_matrix <- function(depot, customers) {
  points <- rbind(depot, customers)
  n <- nrow(points)
  dist_matrix <- matrix(0, n, n)
  
  for (i in 1:n) {
    for (j in 1:n) {
      if (i != j) {
        dist_matrix[i, j] <- euclidean_distance(points[i, ], points[j, ])
      }
    }
  }
  
  return(dist_matrix)
}

# Function to calculate route distance
calculate_route_distance <- function(route, distance_matrix) {
  if (length(route) == 0) {
    return(0)
  }
  
  distance <- 0
  
  # Depot to first customer
  distance <- distance + distance_matrix[1, route[1] + 1]
  
  # Between customers
  if (length(route) > 1) {
    for (i in 1:(length(route) - 1)) {
      distance <- distance + distance_matrix[route[i] + 1, route[i + 1] + 1]
    }
  }
  
  # Last customer to depot
  distance <- distance + distance_matrix[route[length(route)] + 1, 1]
  
  return(distance)
}

# Function to calculate total distance for all routes
calculate_total_distance <- function(routes, distance_matrix) {
  sum(sapply(routes, function(route) calculate_route_distance(route, distance_matrix)))
}

# Function to check if a route is feasible (capacity constraint)
is_route_feasible <- function(route, demands, vehicle_capacity) {
  sum(demands[route]) <= vehicle_capacity
}

# Function to improve a single route using 2-opt moves
improve_route_2opt <- function(route, demands, vehicle_capacity, distance_matrix) {
  if (length(route) < 3) {
    return(list(route = route, improvement = 0))
  }
  
  best_route <- route
  best_distance <- calculate_route_distance(route, distance_matrix)
  best_improvement <- 0
  
  n <- length(route)
  
  # Try all possible 2-opt moves
  for (i in 1:(n - 1)) {
    for (j in (i + 2):n) {
      if (j <= n) {
        # Create new route by reversing the segment between i+1 and j
        new_route <- route
        new_route[(i + 1):j] <- rev(new_route[(i + 1):j])
        
        # Check if the new route is feasible (capacity constraint)
        if (!is_route_feasible(new_route, demands, vehicle_capacity)) {
          next
        }
        
        new_distance <- calculate_route_distance(new_route, distance_matrix)
        improvement <- best_distance - new_distance
        
        if (improvement > best_improvement) {
          best_route <- new_route
          best_improvement <- improvement
        }
      }
    }
  }
  
  return(list(route = best_route, improvement = best_improvement))
}

# Main function to improve a VRP solution using 2-opt local search
improve_solution_2opt <- function(initial_routes, depot, customers, demands, vehicle_capacity, max_iterations = 1000) {
  distance_matrix <- compute_distance_matrix(depot, customers)
  current_routes <- initial_routes
  current_distance <- calculate_total_distance(current_routes, distance_matrix)
  
  improvement_found <- TRUE
  iterations_without_improvement <- 0
  total_iterations <- 0
  
  cat(sprintf("Initial solution distance: %.2f\n", current_distance))
  
  while (improvement_found && iterations_without_improvement < max_iterations) {
    improvement_found <- FALSE
    total_iterations <- total_iterations + 1
    
    # Try to improve each route
    for (route_idx in seq_along(current_routes)) {
      route <- current_routes[[route_idx]]
      
      if (length(route) < 3) {
        next  # Need at least 3 customers for 2-opt
      }
      
      result <- improve_route_2opt(route, demands, vehicle_capacity, distance_matrix)
      
      if (result$improvement > 0.001) {  # Significant improvement threshold
        current_routes[[route_idx]] <- result$route
        current_distance <- current_distance - result$improvement
        improvement_found <- TRUE
        iterations_without_improvement <- 0
        cat(sprintf("Iteration %d: Route %d improved by %.2f\n", total_iterations, route_idx, result$improvement))
        break  # Restart from the beginning after an improvement
      }
    }
    
    if (!improvement_found) {
      iterations_without_improvement <- iterations_without_improvement + 1
    }
  }
  
  cat(sprintf("Final solution distance: %.2f\n", current_distance))
  cat(sprintf("Total iterations: %d\n", total_iterations))
  
  return(list(
    routes = current_routes,
    total_distance = current_distance,
    num_vehicles_used = length(current_routes),
    improvement_iterations = total_iterations,
    feasible = all(sapply(current_routes, function(route) is_route_feasible(route, demands, vehicle_capacity)))
  ))
}

# Function for inter-route 2-opt (swapping customers between routes)
inter_route_2opt <- function(initial_routes, depot, customers, demands, vehicle_capacity, max_iterations = 500) {
  distance_matrix <- compute_distance_matrix(depot, customers)
  current_routes <- initial_routes
  current_distance <- calculate_total_distance(current_routes, distance_matrix)
  
  improvement_found <- TRUE
  iterations_without_improvement <- 0
  total_iterations <- 0
  
  cat(sprintf("Starting inter-route 2-opt with distance: %.2f\n", current_distance))
  
  while (improvement_found && iterations_without_improvement < max_iterations) {
    improvement_found <- FALSE
    total_iterations <- total_iterations + 1
    
    # Try swapping customers between different routes
    for (i in 1:length(current_routes)) {
      for (j in (i + 1):length(current_routes)) {
        if (j <= length(current_routes) && length(current_routes[[i]]) > 0 && length(current_routes[[j]]) > 0) {
          
          # Try swapping each customer from route i with each customer from route j
          for (ci in 1:length(current_routes[[i]])) {
            for (cj in 1:length(current_routes[[j]])) {
              # Create new routes with swapped customers
              new_route_i <- current_routes[[i]]
              new_route_j <- current_routes[[j]]
              
              # Swap customers
              temp <- new_route_i[ci]
              new_route_i[ci] <- new_route_j[cj]
              new_route_j[cj] <- temp
              
              # Check feasibility
              if (is_route_feasible(new_route_i, demands, vehicle_capacity) && 
                  is_route_feasible(new_route_j, demands, vehicle_capacity)) {
                
                # Calculate improvement
                old_distance <- calculate_route_distance(current_routes[[i]], distance_matrix) + 
                               calculate_route_distance(current_routes[[j]], distance_matrix)
                new_distance <- calculate_route_distance(new_route_i, distance_matrix) + 
                               calculate_route_distance(new_route_j, distance_matrix)
                
                if (new_distance < old_distance - 0.001) {  # Improvement threshold
                  improvement <- old_distance - new_distance
                  current_routes[[i]] <- new_route_i
                  current_routes[[j]] <- new_route_j
                  current_distance <- current_distance - improvement
                  improvement_found <- TRUE
                  iterations_without_improvement <- 0
                  cat(sprintf("Inter-route iteration %d: Swapped customers between routes %d and %d, improvement: %.2f\n", 
                              total_iterations, i, j, improvement))
                  break
                }
              }
            }
            if (improvement_found) break
          }
          if (improvement_found) break
        }
      }
      if (improvement_found) break
    }
    
    if (!improvement_found) {
      iterations_without_improvement <- iterations_without_improvement + 1
    }
  }
  
  cat(sprintf("Final inter-route distance: %.2f\n", current_distance))
  
  return(list(
    routes = current_routes,
    total_distance = current_distance,
    num_vehicles_used = length(current_routes),
    improvement_iterations = total_iterations,
    feasible = all(sapply(current_routes, function(route) is_route_feasible(route, demands, vehicle_capacity)))
  ))
}

# Function to get detailed route information
get_route_info <- function(route, demands, vehicle_capacity, distance_matrix) {
  if (length(route) == 0) {
    return(list(distance = 0, load = 0, customers = integer(0), feasible = TRUE))
  }
  
  total_load <- sum(demands[route])
  distance <- calculate_route_distance(route, distance_matrix)
  
  return(list(
    distance = distance,
    load = total_load,
    customers = route,
    capacity_utilization = total_load / vehicle_capacity,
    feasible = is_route_feasible(route, demands, vehicle_capacity)
  ))
}

# Example usage function
run_two_opt_example <- function() {
  cat("=== 2-opt VRP Improvement ===\n")
  
  # Example problem instance
  depot <- c(0, 0)
  customers <- matrix(c(
    4, 4,
    6, 2,
    8, 6,
    2, 8,
    10, 4,
    12, 2
  ), ncol = 2, byrow = TRUE)
  
  demands <- c(3, 5, 2, 4, 6, 3)
  vehicle_capacity <- 10
  
  # Initial solution (could come from nearest neighbor or savings algorithm)
  initial_routes <- list(
    c(1, 3, 4),  # Vehicle 1: customers 1, 3, 4
    c(2, 5),     # Vehicle 2: customers 2, 5
    c(6)         # Vehicle 3: customer 6
  )
  
  distance_matrix <- compute_distance_matrix(depot, customers)
  
  # Print initial solution
  cat("\nInitial Solution:\n")
  initial_distance <- calculate_total_distance(initial_routes, distance_matrix)
  cat(sprintf("Total Distance: %.2f\n", initial_distance))
  
  for (i in seq_along(initial_routes)) {
    route <- initial_routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("  Distance: %.2f, Load: %d/%d\n", route_info$distance, route_info$load, vehicle_capacity))
  }
  
  # Apply intra-route 2-opt improvement
  cat("\n--- Applying Intra-route 2-opt ---\n")
  improved_solution <- improve_solution_2opt(initial_routes, depot, customers, demands, vehicle_capacity, max_iterations = 100)
  
  cat(sprintf("\nImproved Solution (Intra-route):\n"))
  cat(sprintf("Total Distance: %.2f\n", improved_solution$total_distance))
  cat(sprintf("Improvement: %.2f\n", initial_distance - improved_solution$total_distance))
  
  for (i in seq_along(improved_solution$routes)) {
    route <- improved_solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("  Distance: %.2f, Load: %d/%d\n", route_info$distance, route_info$load, vehicle_capacity))
  }
  
  # Apply inter-route 2-opt improvement
  cat("\n--- Applying Inter-route 2-opt ---\n")
  final_solution <- inter_route_2opt(improved_solution$routes, depot, customers, demands, vehicle_capacity, max_iterations = 100)
  
  cat(sprintf("\nFinal Solution (Inter-route):\n"))
  cat(sprintf("Total Distance: %.2f\n", final_solution$total_distance))
  cat(sprintf("Total Improvement: %.2f\n", initial_distance - final_solution$total_distance))
  
  for (i in seq_along(final_solution$routes)) {
    route <- final_solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("  Distance: %.2f, Load: %d/%d\n", route_info$distance, route_info$load, vehicle_capacity))
  }
  
  return(final_solution)
}

# Run example if script is executed directly
if (!interactive()) {
  run_two_opt_example()
}