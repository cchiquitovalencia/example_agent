# VRP Heuristics Comparison and Hybrid Approach
#
# This script demonstrates the use of three VRP heuristics:
# 1. Nearest Neighbor Heuristic (constructive)
# 2. Clarke-Wright Savings Algorithm (constructive)
# 3. 2-opt Local Search (improvement)

# Source the individual heuristic files
source("nearest_neighbor_heuristic.R")
source("savings_algorithm.R")
source("two_opt_improvement.R")

# Function to print solution summary
print_solution_summary <- function(name, solution, solve_time) {
  cat(sprintf("\n=== %s ===\n", name))
  cat(sprintf("Total Distance: %.2f\n", solution$total_distance))
  cat(sprintf("Vehicles Used: %d\n", solution$num_vehicles_used))
  cat(sprintf("Feasible: %s\n", solution$feasible))
  cat(sprintf("Solve Time: %.4f seconds\n", solve_time))
  
  if (length(solution$unvisited_customers) > 0) {
    unvisited_str <- paste(solution$unvisited_customers, collapse = ", ")
    cat(sprintf("Unvisited customers: %s\n", unvisited_str))
  }
}

# Main comparison function
compare_vrp_heuristics <- function() {
  cat("Vehicle Routing Problem - Heuristics Comparison\n")
  cat("==================================================\n")
  
  # Problem instance
  depot <- c(0, 0)
  customers <- matrix(c(
    4, 4,
    6, 2,
    8, 6,
    2, 8,
    10, 4,
    12, 2,
    14, 6,
    3, 1,
    9, 9,
    11, 8,
    1, 5,
    13, 3
  ), ncol = 2, byrow = TRUE)
  
  demands <- c(3, 5, 2, 4, 6, 3, 4, 2, 5, 3, 4, 2)
  vehicle_capacity <- 15
  num_vehicles <- 4
  
  cat(sprintf("Number of customers: %d\n", nrow(customers)))
  cat(sprintf("Vehicle capacity: %d\n", vehicle_capacity))
  cat(sprintf("Number of vehicles: %d\n", num_vehicles))
  cat(sprintf("Total demand: %d\n", sum(demands)))
  
  # 1. Nearest Neighbor Heuristic
  cat("\n==================================================\n")
  cat("1. NEAREST NEIGHBOR HEURISTIC\n")
  cat("==================================================\n")
  
  start_time <- Sys.time()
  nn_solution <- nearest_neighbor_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  nn_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  print_solution_summary("Nearest Neighbor", nn_solution, nn_time)
  
  # Print detailed routes
  distance_matrix_nn <- compute_distance_matrix(depot, customers)
  for (i in seq_along(nn_solution$routes)) {
    route <- nn_solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix_nn)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("  Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("    Distance: %.2f, Load: %d/%d\n", route_info$distance, route_info$load, vehicle_capacity))
  }
  
  # 2. Clarke-Wright Savings Algorithm
  cat("\n==================================================\n")
  cat("2. CLARKE-WRIGHT SAVINGS ALGORITHM\n")
  cat("==================================================\n")
  
  start_time <- Sys.time()
  cw_solution <- savings_algorithm_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  cw_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  
  print_solution_summary("Clarke-Wright Savings", cw_solution, cw_time)
  
  # Print top savings
  cat("\nTop 5 Savings computed:\n")
  top_savings <- head(cw_solution$savings_list, 5)
  for (i in 1:nrow(top_savings)) {
    cat(sprintf("  %d. Customers %d-%d: Savings = %.2f\n", 
                i, top_savings[i, ]$customer_i, top_savings[i, ]$customer_j, top_savings[i, ]$savings_value))
  }
  
  # Print detailed routes
  distance_matrix_cw <- compute_distance_matrix(depot, customers)
  for (i in seq_along(cw_solution$routes)) {
    route <- cw_solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix_cw)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("  Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("    Distance: %.2f, Load: %d/%d\n", route_info$distance, route_info$load, vehicle_capacity))
  }
  
  # 3. Improve solutions with 2-opt
  cat("\n==================================================\n")
  cat("3. 2-OPT IMPROVEMENT\n")
  cat("==================================================\n")
  
  # Improve Nearest Neighbor solution
  cat("\nImproving Nearest Neighbor solution with 2-opt:\n")
  if (length(nn_solution$routes) > 0) {
    start_time <- Sys.time()
    improved_nn <- improve_solution_2opt(nn_solution$routes, depot, customers, demands, vehicle_capacity, max_iterations = 100)
    opt_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    cat(sprintf("Original NN distance: %.2f\n", nn_solution$total_distance))
    cat(sprintf("Improved distance: %.2f\n", improved_nn$total_distance))
    cat(sprintf("Improvement: %.2f\n", nn_solution$total_distance - improved_nn$total_distance))
    cat(sprintf("Improvement time: %.4f seconds\n", opt_time))
  } else {
    cat("No routes to improve in Nearest Neighbor solution\n")
    improved_nn <- NULL
  }
  
  # Improve Clarke-Wright solution
  cat("\nImproving Clarke-Wright solution with 2-opt:\n")
  if (length(cw_solution$routes) > 0) {
    start_time <- Sys.time()
    improved_cw <- improve_solution_2opt(cw_solution$routes, depot, customers, demands, vehicle_capacity, max_iterations = 100)
    opt_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    cat(sprintf("Original CW distance: %.2f\n", cw_solution$total_distance))
    cat(sprintf("Improved distance: %.2f\n", improved_cw$total_distance))
    cat(sprintf("Improvement: %.2f\n", cw_solution$total_distance - improved_cw$total_distance))
    cat(sprintf("Improvement time: %.4f seconds\n", opt_time))
  } else {
    cat("No routes to improve in Clarke-Wright solution\n")
    improved_cw <- NULL
  }
  
  # Summary comparison
  cat("\n==================================================\n")
  cat("FINAL COMPARISON\n")
  cat("==================================================\n")
  
  results <- list()
  if (nn_solution$feasible) {
    final_nn_distance <- ifelse(is.null(improved_nn), nn_solution$total_distance, improved_nn$total_distance)
    results <- append(results, list(list(method = "Nearest Neighbor (+ 2-opt)", 
                                         distance = final_nn_distance, 
                                         vehicles = nn_solution$num_vehicles_used)))
  }
  
  if (cw_solution$feasible) {
    final_cw_distance <- ifelse(is.null(improved_cw), cw_solution$total_distance, improved_cw$total_distance)
    results <- append(results, list(list(method = "Clarke-Wright (+ 2-opt)", 
                                         distance = final_cw_distance, 
                                         vehicles = cw_solution$num_vehicles_used)))
  }
  
  if (length(results) > 0) {
    # Sort results by distance
    distances <- sapply(results, function(x) x$distance)
    sorted_indices <- order(distances)
    
    cat("Ranking by total distance:\n")
    for (i in seq_along(sorted_indices)) {
      idx <- sorted_indices[i]
      result <- results[[idx]]
      cat(sprintf("  %d. %s: %.2f (using %d vehicles)\n", 
                  i, result$method, result$distance, result$vehicles))
    }
  }
  
  return(list(
    nearest_neighbor = nn_solution,
    clarke_wright = cw_solution,
    improved_nn = improved_nn,
    improved_cw = improved_cw
  ))
}

# Function to demonstrate hybrid approach
demonstrate_hybrid_approach <- function() {
  cat("\n======================================================================\n")
  cat("HYBRID APPROACH: BEST CONSTRUCTIVE + 2-OPT + INTER-ROUTE 2-OPT\n")
  cat("======================================================================\n")
  
  # Same problem instance
  depot <- c(0, 0)
  customers <- matrix(c(
    4, 4,
    6, 2,
    8, 6,
    2, 8,
    10, 4,
    12, 2,
    14, 6,
    3, 1,
    9, 9,
    11, 8,
    1, 5,
    13, 3
  ), ncol = 2, byrow = TRUE)
  
  demands <- c(3, 5, 2, 4, 6, 3, 4, 2, 5, 3, 4, 2)
  vehicle_capacity <- 15
  num_vehicles <- 4
  
  # Try both constructive heuristics
  nn_solution <- nearest_neighbor_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  cw_solution <- savings_algorithm_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
  
  # Choose the better initial solution
  if (nn_solution$feasible && cw_solution$feasible) {
    if (nn_solution$total_distance <= cw_solution$total_distance) {
      best_initial <- nn_solution
      best_method <- "Nearest Neighbor"
    } else {
      best_initial <- cw_solution
      best_method <- "Clarke-Wright"
    }
  } else if (nn_solution$feasible) {
    best_initial <- nn_solution
    best_method <- "Nearest Neighbor"
  } else if (cw_solution$feasible) {
    best_initial <- cw_solution
    best_method <- "Clarke-Wright"
  } else {
    cat("No feasible solution found!\n")
    return(NULL)
  }
  
  cat(sprintf("Best initial solution: %s with distance %.2f\n", best_method, best_initial$total_distance))
  
  # Apply improvements
  # Step 1: Intra-route 2-opt
  cat("\nStep 1: Applying intra-route 2-opt...\n")
  step1_solution <- improve_solution_2opt(best_initial$routes, depot, customers, demands, vehicle_capacity, max_iterations = 200)
  
  # Step 2: Inter-route 2-opt
  cat("\nStep 2: Applying inter-route 2-opt...\n")
  final_solution <- inter_route_2opt(step1_solution$routes, depot, customers, demands, vehicle_capacity, max_iterations = 200)
  
  # Summary
  cat(sprintf("\nHYBRID APPROACH RESULTS:\n"))
  cat(sprintf("Initial (%s): %.2f\n", best_method, best_initial$total_distance))
  cat(sprintf("After intra-route 2-opt: %.2f\n", step1_solution$total_distance))
  cat(sprintf("After inter-route 2-opt: %.2f\n", final_solution$total_distance))
  cat(sprintf("Total improvement: %.2f\n", best_initial$total_distance - final_solution$total_distance))
  improvement_pct <- ((best_initial$total_distance - final_solution$total_distance) / best_initial$total_distance) * 100
  cat(sprintf("Improvement percentage: %.1f%%\n", improvement_pct))
  
  cat(sprintf("\nFinal routes:\n"))
  distance_matrix <- compute_distance_matrix(depot, customers)
  for (i in seq_along(final_solution$routes)) {
    route <- final_solution$routes[[i]]
    route_info <- get_route_info(route, demands, vehicle_capacity, distance_matrix)
    route_str <- paste(route, collapse = " -> ")
    cat(sprintf("  Vehicle %d: Depot -> %s -> Depot\n", i, route_str))
    cat(sprintf("    Distance: %.2f, Load: %d/%d (%.1f%%)\n", 
                route_info$distance, route_info$load, vehicle_capacity, 
                route_info$capacity_utilization * 100))
  }
  
  return(final_solution)
}

# Function to print heuristics summary
print_heuristics_summary <- function() {
  cat("\n======================================================================\n")
  cat("HEURISTICS SUMMARY\n")
  cat("======================================================================\n")
  cat("1. Nearest Neighbor: Fast, greedy constructive heuristic\n")
  cat("   - Good for quick solutions\n")
  cat("   - May not find optimal routes\n")
  cat("\n")
  cat("2. Clarke-Wright Savings: Classical VRP heuristic\n")
  cat("   - Considers global savings\n")
  cat("   - Often produces better initial solutions\n")
  cat("\n")
  cat("3. 2-opt Local Search: Improvement heuristic\n")
  cat("   - Refines existing solutions\n")
  cat("   - Can be applied to any initial solution\n")
  cat("   - Both intra-route and inter-route variants\n")
  cat("\n")
  cat("4. Hybrid Approach: Combines the best of all methods\n")
  cat("   - Use best constructive heuristic as starting point\n")
  cat("   - Apply multiple improvement phases\n")
  cat("   - Generally produces the best results\n")
}

# Main execution function
main <- function() {
  # Run comparison of individual heuristics
  results <- compare_vrp_heuristics()
  
  # Demonstrate hybrid approach
  hybrid_result <- demonstrate_hybrid_approach()
  
  # Print summary
  print_heuristics_summary()
  
  return(list(
    comparison_results = results,
    hybrid_result = hybrid_result
  ))
}

# Run the main function if script is executed directly
if (!interactive()) {
  main()
}