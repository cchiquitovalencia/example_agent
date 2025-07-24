# Unit Tests for Problem Definition Functions
# Author: AI Assistant

library(testthat)

# Source the functions to test
source("R/problem_definition.R")

test_that("generate_problem_instance creates valid structure", {
  problem <- generate_problem_instance(
    num_depots = 2,
    num_customers = 5,
    num_vehicles = 3,
    num_vehicle_types = 2
  )
  
  # Test structure exists
  expect_true(is.list(problem))
  expect_true("depots" %in% names(problem))
  expect_true("customers" %in% names(problem))
  expect_true("vehicles" %in% names(problem))
  expect_true("vehicle_types" %in% names(problem))
  expect_true("distance_matrix" %in% names(problem))
  expect_true("time_matrix" %in% names(problem))
  
  # Test dimensions
  expect_equal(nrow(problem$depots), 2)
  expect_equal(nrow(problem$customers), 5)
  expect_equal(nrow(problem$vehicles), 3)
  expect_equal(nrow(problem$vehicle_types), 2)
  expect_equal(nrow(problem$distance_matrix), 7)  # 2 depots + 5 customers
  expect_equal(ncol(problem$distance_matrix), 7)
})

test_that("generate_problem_instance handles different sizes", {
  # Small instance
  small_problem <- generate_problem_instance(1, 2, 1, 1)
  expect_equal(nrow(small_problem$depots), 1)
  expect_equal(nrow(small_problem$customers), 2)
  expect_equal(nrow(small_problem$vehicles), 1)
  
  # Larger instance
  large_problem <- generate_problem_instance(3, 10, 5, 3)
  expect_equal(nrow(large_problem$depots), 3)
  expect_equal(nrow(large_problem$customers), 10)
  expect_equal(nrow(large_problem$vehicles), 5)
  expect_equal(nrow(large_problem$vehicle_types), 3)
})

test_that("generate_problem_instance uses seed correctly", {
  problem1 <- generate_problem_instance(seed = 123)
  problem2 <- generate_problem_instance(seed = 123)
  problem3 <- generate_problem_instance(seed = 456)
  
  # Same seed should produce same results
  expect_equal(problem1$depots$x, problem2$depots$x)
  expect_equal(problem1$customers$demand, problem2$customers$demand)
  
  # Different seed should produce different results
  expect_false(all(problem1$depots$x == problem3$depots$x))
})

test_that("depot data is valid", {
  problem <- generate_problem_instance()
  
  expect_true(all(problem$depots$x >= 0))
  expect_true(all(problem$depots$x <= 100))
  expect_true(all(problem$depots$y >= 0))
  expect_true(all(problem$depots$y <= 100))
  expect_true(all(problem$depots$capacity > 0))
  expect_true(all(problem$depots$open_time >= 0))
  expect_true(all(problem$depots$close_time > problem$depots$open_time))
})

test_that("customer data is valid", {
  problem <- generate_problem_instance()
  
  expect_true(all(problem$customers$x >= 0))
  expect_true(all(problem$customers$x <= 100))
  expect_true(all(problem$customers$y >= 0))
  expect_true(all(problem$customers$y <= 100))
  expect_true(all(problem$customers$demand > 0))
  expect_true(all(problem$customers$service_time > 0))
  expect_true(all(problem$customers$early_time >= 0))
  expect_true(all(problem$customers$late_time >= problem$customers$early_time))
})

test_that("vehicle types are correctly defined", {
  problem <- generate_problem_instance(num_vehicle_types = 2)
  
  expect_equal(nrow(problem$vehicle_types), 2)
  expect_true(all(problem$vehicle_types$capacity > 0))
  expect_true(all(problem$vehicle_types$speed > 0))
  expect_true(all(problem$vehicle_types$fixed_cost > 0))
  expect_true(all(problem$vehicle_types$variable_cost > 0))
  
  # Check specific values for known types
  expect_equal(problem$vehicle_types$type_name[1], "Small Van")
  expect_equal(problem$vehicle_types$type_name[2], "Large Truck")
  expect_equal(problem$vehicle_types$capacity[1], 100)
  expect_equal(problem$vehicle_types$capacity[2], 200)
})

test_that("vehicles are correctly assigned to depots and types", {
  problem <- generate_problem_instance(
    num_depots = 2,
    num_vehicles = 4,
    num_vehicle_types = 2
  )
  
  # All vehicles should be assigned to valid depots
  expect_true(all(problem$vehicles$depot_id %in% 1:2))
  
  # All vehicles should be assigned to valid types
  expect_true(all(problem$vehicles$type_id %in% 1:2))
  
  # Vehicle should inherit properties from types
  expect_true(all(problem$vehicles$capacity %in% c(100, 200)))
})

test_that("distance matrix is symmetric and valid", {
  problem <- generate_problem_instance()
  dm <- problem$distance_matrix
  
  # Should be square
  expect_equal(nrow(dm), ncol(dm))
  
  # Diagonal should be zero
  expect_true(all(diag(dm) == 0))
  
  # Should be symmetric
  expect_true(all(dm == t(dm)))
  
  # All distances should be non-negative
  expect_true(all(dm >= 0))
})

test_that("generate_problem_summary works correctly", {
  problem <- generate_problem_instance()
  summary_text <- generate_problem_summary(problem)
  
  expect_true(is.character(summary_text))
  expect_true(length(summary_text) == 1)
  expect_true(nchar(summary_text) > 0)
  expect_true(grepl("MDVRPTWH", summary_text))
  expect_true(grepl("Depots:", summary_text))
  expect_true(grepl("Customers:", summary_text))
})

test_that("generate_problem_summary handles NULL input", {
  summary_text <- generate_problem_summary(NULL)
  expect_equal(summary_text, "No problem instance available.")
})

test_that("validate_problem_instance works correctly", {
  # Valid problem
  problem <- generate_problem_instance()
  validation <- validate_problem_instance(problem)
  
  expect_true(validation$valid)
  expect_equal(length(validation$errors), 0)
})

test_that("validate_problem_instance detects missing components", {
  problem <- generate_problem_instance()
  problem$depots <- NULL
  
  validation <- validate_problem_instance(problem)
  expect_false(validation$valid)
  expect_true(length(validation$errors) > 0)
  expect_true(any(grepl("Missing component", validation$errors)))
})

test_that("validate_problem_instance detects empty data", {
  problem <- generate_problem_instance()
  problem$customers <- data.frame()
  
  validation <- validate_problem_instance(problem)
  expect_false(validation$valid)
  expect_true(any(grepl("No customers", validation$errors)))
})

test_that("validate_problem_instance detects invalid time windows", {
  problem <- generate_problem_instance()
  problem$customers$late_time[1] <- problem$customers$early_time[1] - 10
  
  validation <- validate_problem_instance(problem)
  expect_false(validation$valid)
  expect_true(any(grepl("Invalid time windows", validation$errors)))
})

test_that("validate_problem_instance warns about capacity issues", {
  problem <- generate_problem_instance()
  # Make demands very high
  problem$customers$demand <- rep(1000, nrow(problem$customers))
  
  validation <- validate_problem_instance(problem)
  expect_true(any(grepl("demand exceeds", validation$warnings)))
})

test_that("validate_problem_instance detects wrong matrix dimensions", {
  problem <- generate_problem_instance()
  problem$distance_matrix <- matrix(0, 5, 5)  # Wrong size
  
  validation <- validate_problem_instance(problem)
  expect_false(validation$valid)
  expect_true(any(grepl("Distance matrix dimensions", validation$errors)))
})