# Nearest Neighbor Heuristic for Vehicle Routing Problem (VRP)
#
# This heuristic constructs routes by starting from the depot and repeatedly
# selecting the nearest unvisited customer until vehicle capacity is reached
# or all customers are served.

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

# Function to construct a single route using nearest neighbor
construct_route <- function(unvisited, demands, vehicle_capacity, distance_matrix) {
  if (length(unvisited) == 0) {
    return(list(route = integer(0), distance = 0))
  }
  
  route <- integer(0)
  current_load <- 0
  current_position <- 1  # Start at depot (index 1)
  route_distance <- 0
  
  while (length(unvisited) > 0) {
    # Find nearest feasible customer
    nearest_customer <- NULL
    nearest_distance <- Inf
    
    for (customer_idx in unvisited) {
      # Check capacity constraint
      if (current_load + demands[customer_idx] <= vehicle_capacity) {
        # Distance from current position to customer (customer_idx + 1 in matrix)
        distance <- distance_matrix[current_position, customer_idx + 1]
        if (distance < nearest_distance) {
          nearest_distance <- distance
          nearest_customer <- customer_idx
        }
      }
    }
    
    if (is.null(nearest_customer)) {
      # No feasible customer found
      break
    }
    
    # Add customer to route
    route <- c(route, nearest_customer)
    unvisited <- unvisited[unvisited != nearest_customer]
    current_load <- current_load + demands[nearest_customer]
    route_distance <- route_distance + nearest_distance
    current_position <- nearest_customer + 1  # Update position in distance matrix
  }
  
  # Return to depot
  if (length(route) > 0) {
    route_distance <- route_distance + distance_matrix[current_position, 1]
  }
  
  return(list(route = route, distance = route_distance))
}

# Main function to solve VRP using Nearest Neighbor heuristic
nearest_neighbor_vrp <- function(depot, customers, demands, vehicle_capacity, num_vehicles) {
  num_customers <- nrow(customers)
  distance_matrix <- compute_distance_matrix(depot, customers)
  
  unvisited <- 1:num_customers
  routes <- list()
  total_distance <- 0
  vehicle_count <- 0
  
  while (length(unvisited) > 0 && vehicle_count < num_vehicles) {
    route_result <- construct_route(unvisited, demands, vehicle_capacity, distance_matrix)
    
    if (length(route_result$route) > 0) {
      routes[[length(routes) + 1]] <- route_result$route
      total_distance <- total_distance + route_result$distance
      vehicle_count <- vehicle_count + 1
      
      # Remove visited customers from unvisited list
      unvisited <- unvisited[!unvisited %in% route_result$route]
    } else {
      break  # No more feasible routes
    }
  }
  
  return(list(
    routes = routes,
    total_distance = total_distance,
    num_vehicles_used = length(routes),
    unvisited_customers = unvisited,
    feasible = length(unvisited) == 0
  ))
}

# Function to get detailed route information
get_route_info <- function(route, demands, vehicle_capacity, distance_matrix) {
  if (length(route) == 0) {
    return(list(distance = 0, load = 0, customers = integer(0)))
  }
  
  total_load <- sum(demands[route])
  
  # Calculate route distance
  distance <- distance_matrix[1, route[1] + 1]  # Depot to first customer
  if (length(route) > 1) {
    for (i in 1:(length(route) - 1)) {
      distance <- distance + distance_matrix[route[i] + 1, route[i + 1] + 1]
    }
  }
  distance <- distance + distance_matrix[route[length(route)] + 1, 1]  # Last customer to depot
  
  return(list(
    distance = distance,
    load = total_load,
    customers = route,
    capacity_utilization = total_load / vehicle_capacity
  ))
}

# Example usage function
run_nearest_neighbor_example <- function() {
  cat("=== Nearest Neighbor VRP Solution ===\n")
  
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
  num_vehicles <- 3
  
  # Solve the problem
  solution <- nearest_neighbor_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  distance_matrix <- compute_distance_matrix(depot, customers)
  
  # Print results
  cat(sprintf("Total Distance: %.2f\n", solution$total_distance))
  cat(sprintf("Vehicles Used: %d/%d\n", solution$num_vehicles_used, num_vehicles))
  cat(sprintf("Feasible Solution: %s\n", solution$feasible))
  
  for (i in seq_along(solution$routes)) {
    route <- solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix)
    
    cat(sprintf("\nVehicle %d:\n", i))
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("  Route: Depot -> %s -> Depot\n", route_str))
    cat(sprintf("  Distance: %.2f\n", route_info$distance))
    cat(sprintf("  Load: %d/%d\n", route_info$load, vehicle_capacity))
    cat(sprintf("  Capacity Utilization: %.1f%%\n", route_info$capacity_utilization * 100))
  }
  
  if (length(solution$unvisited_customers) > 0) {
    unvisited_str <- paste(solution$unvisited_customers, collapse = ", ")
    cat(sprintf("\nUnvisited customers: %s\n", unvisited_str))
  }
  
  return(solution)
}

# Run example if script is executed directly
if (!interactive()) {
  run_nearest_neighbor_example()
}