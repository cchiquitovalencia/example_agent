# Unit Tests for Solver Functions
# Author: AI Assistant

library(testthat)

# Source the functions to test
source("R/problem_definition.R")
source("R/solver.R")

test_that("solve_mdvrptwh returns valid solution structure", {
  problem <- generate_problem_instance(
    num_depots = 2,
    num_customers = 5,
    num_vehicles = 2,
    num_vehicle_types = 2,
    seed = 42
  )
  
  solution <- solve_mdvrptwh(problem, method = "nn")
  
  # Test solution structure
  expect_true(is.list(solution))
  expect_true("routes" %in% names(solution))
  expect_true("cost" %in% names(solution))
  expect_true("status" %in% names(solution))
  expect_true("solve_time" %in% names(solution))
  expect_true("method" %in% names(solution))
  
  # Test solution values
  expect_true(is.list(solution$routes))
  expect_true(is.numeric(solution$cost))
  expect_true(solution$cost >= 0)
  expect_true(solution$status %in% c("OPTIMAL", "INFEASIBLE", "ERROR"))
  expect_true(solution$solve_time >= 0)
  expect_equal(solution$method, "nn")
})

test_that("solve_mdvrptwh handles invalid problem", {
  invalid_problem <- list()
  
  solution <- solve_mdvrptwh(invalid_problem, method = "nn")
  
  expect_equal(solution$status, "ERROR")
  expect_true(grepl("Invalid problem instance", solution$message))
  expect_equal(solution$cost, Inf)
})

test_that("solve_mdvrptwh handles unknown method", {
  problem <- generate_problem_instance(seed = 42)
  
  expect_error(solve_mdvrptwh(problem, method = "unknown_method"))
})

test_that("nearest neighbor algorithm produces valid routes", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 3,
    num_vehicles = 1,
    seed = 42
  )
  
  solution <- solve_nearest_neighbor(problem)
  
  expect_true(is.list(solution))
  expect_true("routes" %in% names(solution))
  expect_true(length(solution$routes) >= 0)
  
  if (length(solution$routes) > 0) {
    route <- solution$routes[[1]]
    
    # Test route structure
    expect_true("vehicle_id" %in% names(route))
    expect_true("depot_id" %in% names(route))
    expect_true("sequence" %in% names(route))
    expect_true("total_distance" %in% names(route))
    expect_true("total_time" %in% names(route))
    expect_true("load" %in% names(route))
    
    # Test route values
    expect_true(route$total_distance >= 0)
    expect_true(route$total_time >= 0)
    expect_true(route$load >= 0)
    expect_true(length(route$sequence) >= 2)  # At least start and end at depot
  }
})

test_that("greedy algorithm produces valid routes", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 3,
    num_vehicles = 1,
    seed = 42
  )
  
  solution <- solve_greedy(problem)
  
  expect_true(is.list(solution))
  expect_true("routes" %in% names(solution))
  
  if (length(solution$routes) > 0) {
    route <- solution$routes[[1]]
    
    # Should start and end at depot
    expect_equal(route$sequence[1], route$depot_id)
    expect_equal(route$sequence[length(route$sequence)], route$depot_id)
    
    # Load should not exceed capacity
    vehicle <- problem$vehicles[problem$vehicles$vehicle_id == route$vehicle_id, ]
    expect_true(route$load <= vehicle$capacity)
  }
})

test_that("simulated annealing works", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 3,
    num_vehicles = 1,
    seed = 42
  )
  
  solution <- solve_simulated_annealing(problem, max_iterations = 10)
  
  expect_true(is.list(solution))
  expect_true("routes" %in% names(solution))
})

test_that("get_distance function works correctly", {
  problem <- generate_problem_instance(seed = 42)
  
  # Distance from location to itself should be 0
  expect_equal(get_distance(problem, 1, 1), 0)
  
  # Distance should be symmetric
  dist_12 <- get_distance(problem, 1, 2)
  dist_21 <- get_distance(problem, 2, 1)
  expect_equal(dist_12, dist_21)
  
  # Distance should be non-negative
  expect_true(dist_12 >= 0)
})

test_that("calculate_total_cost works correctly", {
  problem <- generate_problem_instance(seed = 42)
  
  # Empty routes should have infinite cost
  expect_equal(calculate_total_cost(problem, NULL), Inf)
  expect_equal(calculate_total_cost(problem, list()), Inf)
  
  # Create a simple route
  simple_route <- list(
    vehicle_id = 1,
    depot_id = 1,
    sequence = c(1, 3, 1),  # depot -> customer -> depot
    total_distance = 50,
    load = 20
  )
  
  cost <- calculate_total_cost(problem, list(simple_route))
  expect_true(is.numeric(cost))
  expect_true(cost > 0)
})

test_that("validate_solution works correctly", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 2,
    num_vehicles = 1,
    seed = 42
  )
  
  # Create a valid route
  valid_route <- list(
    vehicle_id = 1,
    depot_id = 1,
    sequence = c(1, 2, 1),  # depot -> customer 1 -> depot
    arrival_times = c(0, 10, 30),
    service_times = c(0, 15, 30),
    load = 20
  )
  
  valid_solution <- list(routes = list(valid_route))
  
  expect_true(validate_solution(problem, valid_solution))
  
  # Test invalid solution (NULL routes)
  invalid_solution <- list(routes = NULL)
  expect_false(validate_solution(problem, invalid_solution))
})

test_that("all algorithms produce feasible solutions", {
  problem <- generate_problem_instance(
    num_depots = 2,
    num_customers = 5,
    num_vehicles = 2,
    seed = 42
  )
  
  methods <- c("nn", "greedy", "sa")
  
  for (method in methods) {
    solution <- solve_mdvrptwh(problem, method = method, max_iterations = 10)
    
    # Should not error out
    expect_true(solution$status %in% c("OPTIMAL", "INFEASIBLE"))
    
    # If solution found, should be valid
    if (solution$status == "OPTIMAL" && !is.null(solution$routes)) {
      expect_true(validate_solution(problem, solution))
    }
  }
})

test_that("calculate_insertion_cost works", {
  problem <- generate_problem_instance(seed = 42)
  vehicle <- problem$vehicles[1, ]
  
  # Simple route: depot -> depot
  route <- list(
    sequence = c(1, 1),
    total_distance = 0
  )
  
  cost <- calculate_insertion_cost(problem, route, 1, 2, vehicle)
  expect_true(is.numeric(cost))
  expect_true(cost >= 0)
  
  # Invalid position should return Inf
  invalid_cost <- calculate_insertion_cost(problem, route, 1, 10, vehicle)
  expect_equal(invalid_cost, Inf)
})

test_that("recalculate_route_metrics works correctly", {
  problem <- generate_problem_instance(seed = 42)
  vehicle <- problem$vehicles[1, ]
  
  route <- list(
    sequence = c(1, 3, 1),  # depot -> customer 1 -> depot
    arrival_times = numeric(3),
    service_times = numeric(3),
    total_distance = 0,
    load = 0
  )
  
  updated_route <- recalculate_route_metrics(problem, route, vehicle)
  
  expect_true(updated_route$total_distance > 0)
  expect_true(updated_route$load > 0)
  expect_equal(length(updated_route$arrival_times), 3)
  expect_equal(length(updated_route$service_times), 3)
})

test_that("generate_neighbor_solution works", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 4,
    num_vehicles = 2,
    seed = 42
  )
  
  # Create initial solution
  initial_solution <- solve_greedy(problem)
  
  if (length(initial_solution$routes) > 0) {
    neighbor <- generate_neighbor_solution(problem, initial_solution)
    
    expect_true(is.list(neighbor))
    expect_true("routes" %in% names(neighbor))
    expect_equal(length(neighbor$routes), length(initial_solution$routes))
  }
})

test_that("solution costs are reasonable", {
  problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 3,
    num_vehicles = 1,
    seed = 42
  )
  
  nn_solution <- solve_mdvrptwh(problem, method = "nn")
  greedy_solution <- solve_mdvrptwh(problem, method = "greedy")
  
  # Both should produce valid costs
  expect_true(is.finite(nn_solution$cost))
  expect_true(is.finite(greedy_solution$cost))
  expect_true(nn_solution$cost > 0)
  expect_true(greedy_solution$cost > 0)
})

test_that("solver handles edge cases", {
  # Single customer
  small_problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 1,
    num_vehicles = 1,
    seed = 42
  )
  
  solution <- solve_mdvrptwh(small_problem, method = "nn")
  expect_true(solution$status %in% c("OPTIMAL", "INFEASIBLE"))
  
  # No vehicles
  no_vehicle_problem <- generate_problem_instance(
    num_depots = 1,
    num_customers = 2,
    num_vehicles = 0,
    seed = 42
  )
  
  # This should handle gracefully (might be infeasible)
  solution <- solve_mdvrptwh(no_vehicle_problem, method = "nn")
  expect_true(solution$status %in% c("OPTIMAL", "INFEASIBLE", "ERROR"))
})