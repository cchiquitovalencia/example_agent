# Test Runner for MDVRPTWH Shiny Application
# Author: AI Assistant

library(testthat)

cat("=== MDVRPTWH Unit Test Suite ===\n\n")

# Set working directory to project root
if (basename(getwd()) == "tests") {
  setwd("..")
}

# Run tests
cat("Running Problem Definition Tests...\n")
test_file("tests/test_problem_definition.R", reporter = "summary")

cat("\nRunning Solver Tests...\n")
test_file("tests/test_solver.R", reporter = "summary")

cat("\n=== Test Suite Complete ===\n")

# Optional: Run all tests in tests directory
cat("\nRunning all tests with detailed output...\n")
test_dir("tests", reporter = "check")

cat("\nFor more detailed output, run individual test files or use:\n")
cat("testthat::test_dir('tests', reporter = 'detailed')\n")