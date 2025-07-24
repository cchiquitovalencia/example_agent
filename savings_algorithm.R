# Clarke-Wright Savings Algorithm for Vehicle Routing Problem (VRP)
#
# This classical heuristic starts with individual routes from depot to each customer
# and then combines routes based on savings calculations to minimize total distance.

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

# Function to calculate savings for all customer pairs
calculate_savings <- function(num_customers, distance_matrix) {
  savings_list <- data.frame(
    customer_i = integer(0),
    customer_j = integer(0),
    savings_value = numeric(0)
  )
  
  for (i in 1:num_customers) {
    for (j in (i + 1):num_customers) {
      if (j <= num_customers) {
        # Savings = d(0,i) + d(0,j) - d(i,j)
        # In distance matrix: depot=1, customer_i=i+1, customer_j=j+1
        depot_to_i <- distance_matrix[1, i + 1]
        depot_to_j <- distance_matrix[1, j + 1]
        i_to_j <- distance_matrix[i + 1, j + 1]
        
        savings_value <- depot_to_i + depot_to_j - i_to_j
        
        savings_list <- rbind(savings_list, data.frame(
          customer_i = i,
          customer_j = j,
          savings_value = savings_value
        ))
      }
    }
  }
  
  # Sort by savings in descending order
  savings_list <- savings_list[order(-savings_list$savings_value), ]
  return(savings_list)
}

# Function to check if two routes can be merged
can_merge_routes <- function(route1, route2, demands, vehicle_capacity, customer_i, customer_j) {
  load1 <- sum(demands[route1])
  load2 <- sum(demands[route2])
  
  # Check capacity constraint
  if (load1 + load2 > vehicle_capacity) {
    return(FALSE)
  }
  
  # Check if customers are at the ends of their respective routes
  i_at_end <- (route1[1] == customer_i || route1[length(route1)] == customer_i)
  j_at_end <- (route2[1] == customer_j || route2[length(route2)] == customer_j)
  
  return(i_at_end && j_at_end)
}

# Function to merge two routes
merge_routes <- function(route1, route2, customer_i, customer_j) {
  # Find positions of customers in their routes
  i_pos <- ifelse(route1[1] == customer_i, 1, length(route1))
  j_pos <- ifelse(route2[1] == customer_j, 1, length(route2))
  
  if (i_pos == length(route1) && j_pos == 1) {
    # customer_i is at end of route1, customer_j is at start of route2
    merged_route <- c(route1, route2)
  } else if (i_pos == 1 && j_pos == length(route2)) {
    # customer_i is at start of route1, customer_j is at end of route2
    merged_route <- c(route2, route1)
  } else if (i_pos == length(route1) && j_pos == length(route2)) {
    # Both at the end - reverse route2 and append
    merged_route <- c(route1, rev(route2))
  } else if (i_pos == 1 && j_pos == 1) {
    # Both at the beginning - reverse route1 and append route2
    merged_route <- c(rev(route1), route2)
  } else {
    # This shouldn't happen if can_merge_routes is correct
    merged_route <- c(route1, route2)
  }
  
  return(merged_route)
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

# Main function to solve VRP using Clarke-Wright Savings Algorithm
savings_algorithm_vrp <- function(depot, customers, demands, vehicle_capacity, num_vehicles) {
  num_customers <- nrow(customers)
  distance_matrix <- compute_distance_matrix(depot, customers)
  savings_list <- calculate_savings(num_customers, distance_matrix)
  
  # Initialize: each customer is in its own route
  routes <- lapply(1:num_customers, function(i) i)
  
  # Keep track of which route each customer belongs to
  customer_to_route <- 1:num_customers
  
  # Process savings in decreasing order
  for (row_idx in 1:nrow(savings_list)) {
    savings_row <- savings_list[row_idx, ]
    customer_i <- savings_row$customer_i
    customer_j <- savings_row$customer_j
    savings_value <- savings_row$savings_value
    
    if (savings_value <= 0) {
      break  # No more positive savings
    }
    
    route_i <- customer_to_route[customer_i]
    route_j <- customer_to_route[customer_j]
    
    # Skip if customers are already in the same route
    if (route_i == route_j) {
      next
    }
    
    # Check if routes can be merged
    if (can_merge_routes(routes[[route_i]], routes[[route_j]], demands, vehicle_capacity, customer_i, customer_j)) {
      # Merge routes
      merged_route <- merge_routes(routes[[route_i]], routes[[route_j]], customer_i, customer_j)
      
      # Update data structures
      routes[[route_i]] <- merged_route
      
      # Update customer-to-route mapping for all customers in route_j
      for (customer in routes[[route_j]]) {
        customer_to_route[customer] <- route_i
      }
      
      # Mark route_j as empty
      routes[[route_j]] <- integer(0)
    }
  }
  
  # Remove empty routes
  final_routes <- routes[sapply(routes, length) > 0]
  
  # Check vehicle limit
  if (length(final_routes) > num_vehicles) {
    # Sort routes by distance and keep only the best ones
    route_distances <- sapply(final_routes, function(route) calculate_route_distance(route, distance_matrix))
    route_order <- order(route_distances)
    final_routes <- final_routes[route_order[1:num_vehicles]]
  }
  
  total_distance <- sum(sapply(final_routes, function(route) calculate_route_distance(route, distance_matrix)))
  
  # Check which customers are served
  served_customers <- unlist(final_routes)
  unvisited <- setdiff(1:num_customers, served_customers)
  
  return(list(
    routes = final_routes,
    total_distance = total_distance,
    num_vehicles_used = length(final_routes),
    unvisited_customers = unvisited,
    feasible = length(unvisited) == 0,
    savings_list = savings_list
  ))
}

# Function to get detailed route information
get_route_info <- function(route, demands, vehicle_capacity, distance_matrix) {
  if (length(route) == 0) {
    return(list(distance = 0, load = 0, customers = integer(0)))
  }
  
  total_load <- sum(demands[route])
  distance <- calculate_route_distance(route, distance_matrix)
  
  return(list(
    distance = distance,
    load = total_load,
    customers = route,
    capacity_utilization = total_load / vehicle_capacity
  ))
}

# Example usage function
run_savings_algorithm_example <- function() {
  cat("=== Clarke-Wright Savings Algorithm VRP Solution ===\n")
  
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
  solution <- savings_algorithm_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  distance_matrix <- compute_distance_matrix(depot, customers)
  
  # Print results
  cat(sprintf("Total Distance: %.2f\n", solution$total_distance))
  cat(sprintf("Vehicles Used: %d/%d\n", solution$num_vehicles_used, num_vehicles))
  cat(sprintf("Feasible Solution: %s\n", solution$feasible))
  
  # Print top savings
  cat("\nTop 5 Savings:\n")
  top_savings <- head(solution$savings_list, 5)
  for (i in 1:nrow(top_savings)) {
    cat(sprintf("  %d. Customers %d-%d: Savings = %.2f\n", 
                i, top_savings[i, ]$customer_i, top_savings[i, ]$customer_j, top_savings[i, ]$savings_value))
  }
  
  # Print detailed routes
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
  run_savings_algorithm_example()
}