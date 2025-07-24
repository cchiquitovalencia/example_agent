# MDVRPTWH Solver - Usage Examples

## Quick Start

### 1. Running the Shiny Web Application

```r
# Install required packages first (if not already installed)
source("install_packages.R")

# Launch the Shiny web application
shiny::runApp("app.R")
```

The application will open in your default web browser at `http://127.0.0.1:XXXX`

### 2. Using the Core Functions Programmatically

```r
# Load the required modules
source("R/problem_definition.R")
source("R/solver.R") 
source("R/visualization.R")

# Generate a small problem instance
# 2 depots, 7 customers, 2 vehicles, 2 vehicle types
problem <- generate_problem_instance(
  num_depots = 2,
  num_customers = 7, 
  num_vehicles = 2,
  num_vehicle_types = 2,
  seed = 42
)

# Solve using different algorithms
nn_solution <- solve_mdvrptwh(problem, method = "nn")
greedy_solution <- solve_mdvrptwh(problem, method = "greedy") 
sa_solution <- solve_mdvrptwh(problem, method = "sa")

# View results
print(nn_solution$cost)        # Total cost
print(nn_solution$status)      # Solution status
print(length(nn_solution$routes))  # Number of routes

# Generate solution summary
summary_text <- generate_solution_summary(nn_solution)
cat(summary_text)
```

## Problem Instance Structure

### Generated Data
- **Depots**: Coordinates, opening hours
- **Customers**: Coordinates, demand, time windows, service time
- **Vehicles**: Type, capacity, depot assignment
- **Vehicle Types**: Capacity, cost per distance

### Example Output
```
$depots
  id         x         y open_time close_time
1  1  26.55087  17.65568         0        480
2  2  37.21239  57.28534         0        480

$customers
  id         x         y demand earliest_time latest_time service_time
1  3  89.82078  94.46753      8            60         420            5
2  4  66.07978  62.91140      9            60         420            5
...

$vehicles
  vehicle_id type_id depot_id
1          1       1        1
2          2       2        2

$vehicle_types
  type_id capacity cost_per_distance
1       1       50              1.0
2       2       75              1.5
```

## Algorithm Comparison

| Algorithm | Description | Pros | Cons |
|-----------|-------------|------|------|
| **Nearest Neighbor (nn)** | Greedy construction | Fast, simple | May get trapped in local optimum |
| **Greedy** | Capacity-first construction | Efficient capacity usage | Limited optimization |
| **Simulated Annealing (sa)** | Metaheuristic optimization | Better solutions | Slower, requires tuning |

## Web Application Features

### 1. Problem Setup Tab
- Adjust problem parameters (depots, customers, vehicles)
- Generate new random instances
- View problem data in tables

### 2. Solution Tab  
- Select solving algorithm
- Configure algorithm parameters
- Run optimization
- View solution details

### 3. Visualization Tab
- Interactive route plots (requires plotly)
- Solution summary statistics
- Algorithm performance comparison

### 4. Documentation Tab
- Access to full documentation
- Algorithm descriptions
- API reference

## Example Solutions

### Small Instance Results
```
Problem: 2 depots, 7 customers, 2 vehicles
- Nearest Neighbor: Cost 560.82, Status: OPTIMAL, Time: 0.003s
- Greedy: Cost 762.88, Status: INFEASIBLE, Time: 0.001s  
- Simulated Annealing: Cost 471.92, Status: INFEASIBLE, Time: 0.015s
```

## Testing

Run the test suite to verify functionality:

```r
# Run comprehensive tests
source("test_app.R")

# Run unit tests (requires testthat)
source("tests/run_tests.R")
```

## Troubleshooting

### Common Issues

1. **Package Installation Errors**
   - Install system dependencies: `sudo apt-get install libssl-dev libcurl4-openssl-dev`
   - Try installing packages individually

2. **Plotly Not Working**
   - The app works without plotly but with reduced visualization
   - Install additional dependencies if needed

3. **Shiny App Won't Start**
   - Check working directory is set to project root
   - Verify all R modules load correctly
   - Run `test_app.R` to diagnose issues

For more detailed information, see the documentation in the `docs/` directory.