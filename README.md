# Vehicle Routing Problem (VRP) Heuristics in R

This repository contains R implementations of three different heuristics for solving the Vehicle Routing Problem (VRP):

1. **Nearest Neighbor Heuristic** - A constructive greedy algorithm
2. **Clarke-Wright Savings Algorithm** - A classical VRP constructive heuristic  
3. **2-opt Local Search** - An improvement heuristic for route optimization

## Files Description

- `nearest_neighbor_heuristic.R` - Nearest Neighbor implementation
- `savings_algorithm.R` - Clarke-Wright Savings Algorithm implementation
- `two_opt_improvement.R` - 2-opt local search improvement heuristic
- `vrp_example.R` - Example script demonstrating all heuristics and comparisons

## Problem Definition

The Vehicle Routing Problem involves:
- A depot at coordinates (x, y)
- A set of customers with known locations and demands
- A fleet of vehicles with limited capacity
- Objective: Minimize total travel distance while serving all customers

## Heuristics Overview

### 1. Nearest Neighbor Heuristic
**Type:** Constructive  
**Approach:** Greedy route construction  
**Algorithm:**
- Start at depot
- Repeatedly visit the nearest unvisited customer
- Respect vehicle capacity constraints
- Return to depot when no more customers can be added

**Characteristics:**
- Fast execution
- Simple to implement
- Often produces good initial solutions
- May not find globally optimal routes

### 2. Clarke-Wright Savings Algorithm
**Type:** Constructive  
**Approach:** Route merging based on savings  
**Algorithm:**
- Start with individual routes from depot to each customer
- Calculate savings for merging routes: S(i,j) = d(0,i) + d(0,j) - d(i,j)
- Sort savings in descending order
- Merge routes when feasible and beneficial

**Characteristics:**
- Classical VRP algorithm (1964)
- Considers global route structure
- Often produces better solutions than greedy approaches
- Computationally efficient

### 3. 2-opt Local Search
**Type:** Improvement  
**Approach:** Local optimization of existing routes  
**Algorithm:**
- Take an existing route
- Try all possible 2-opt moves (edge swaps)
- Accept improvements that reduce total distance
- Continue until no more improvements found

**Features:**
- Intra-route optimization (within single routes)
- Inter-route optimization (between different routes)
- Can improve any initial solution
- Iterative improvement process

## Usage

### Running Individual Heuristics

```r
# Source the required file
source("nearest_neighbor_heuristic.R")

# Define problem instance
depot <- c(0, 0)
customers <- matrix(c(4, 4, 6, 2, 8, 6), ncol = 2, byrow = TRUE)
demands <- c(3, 5, 2)
vehicle_capacity <- 10
num_vehicles <- 2

# Solve using Nearest Neighbor
solution <- nearest_neighbor_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
```

```r
# Clarke-Wright Savings
source("savings_algorithm.R")
solution <- savings_algorithm_vrp(depot, customers, demands, vehicle_capacity, num_vehicles)
```

```r
# 2-opt Improvement
source("two_opt_improvement.R")
initial_routes <- list(c(1, 2), c(3))  # Initial solution
improved_solution <- improve_solution_2opt(initial_routes, depot, customers, demands, vehicle_capacity)
```

### Running Comprehensive Example

```bash
Rscript vrp_example.R
```

This will:
- Compare all three heuristics on the same problem
- Show performance metrics and solution quality
- Demonstrate a hybrid approach combining multiple methods
- Provide detailed analysis and recommendations

### Interactive Usage in R

```r
# Source all files
source("vrp_example.R")

# Run comparison
results <- compare_vrp_heuristics()

# Run hybrid approach
hybrid_result <- demonstrate_hybrid_approach()

# Print summary
print_heuristics_summary()
```

## Solution Format

All heuristics return solutions in the same format:

```r
list(
  routes = list(c(1, 3), c(2, 4)),  # List of routes (customer indices)
  total_distance = 25.4,            # Total travel distance
  num_vehicles_used = 2,            # Number of vehicles used
  unvisited_customers = integer(0), # Customers not served (if any)
  feasible = TRUE                   # Whether solution is feasible
)
```

## Data Structures

### Input Format
- **depot**: Vector of coordinates `c(x, y)`
- **customers**: Matrix with 2 columns (x, y coordinates), one row per customer
- **demands**: Vector of demand values for each customer
- **vehicle_capacity**: Single numeric value
- **num_vehicles**: Single integer value

### Example
```r
depot <- c(0, 0)
customers <- matrix(c(
  4, 4,
  6, 2,
  8, 6
), ncol = 2, byrow = TRUE)
demands <- c(3, 5, 2)
vehicle_capacity <- 10
num_vehicles <- 2
```

## Algorithm Complexity

- **Nearest Neighbor:** O(n²) where n = number of customers
- **Clarke-Wright:** O(n²) for savings calculation + O(n²) for merging
- **2-opt:** O(n²) per iteration × number of iterations

## Best Practices

1. **For quick solutions:** Use Nearest Neighbor
2. **For better quality:** Use Clarke-Wright Savings
3. **For optimization:** Apply 2-opt to improve any initial solution
4. **For best results:** Use hybrid approach (constructive + improvement)

## Dependencies

The code uses only base R functions and requires no additional packages:
- `matrix()` for data structures
- `rbind()`, `c()` for data manipulation
- `sqrt()` for distance calculations
- `sprintf()`, `cat()` for output formatting

## Example Output

```
Vehicle Routing Problem - Heuristics Comparison
==================================================
Number of customers: 12
Vehicle capacity: 15
Number of vehicles: 4
Total demand: 43

=== Nearest Neighbor ===
Total Distance: 45.23
Vehicles Used: 3
Feasible: TRUE

=== Clarke-Wright Savings ===
Total Distance: 42.17
Vehicles Used: 3
Feasible: TRUE

=== Hybrid Approach ===
Initial (Clarke-Wright): 42.17
After intra-route 2-opt: 40.85
After inter-route 2-opt: 39.92
Total improvement: 2.25
```

## Function Reference

### Core Functions

- `nearest_neighbor_vrp()` - Main nearest neighbor solver
- `savings_algorithm_vrp()` - Main Clarke-Wright solver
- `improve_solution_2opt()` - Intra-route 2-opt improvement
- `inter_route_2opt()` - Inter-route 2-opt improvement

### Utility Functions

- `compute_distance_matrix()` - Calculate distance matrix
- `calculate_route_distance()` - Calculate single route distance
- `get_route_info()` - Get detailed route information
- `is_route_feasible()` - Check capacity constraints

### Example Functions

- `run_nearest_neighbor_example()` - Example for nearest neighbor
- `run_savings_algorithm_example()` - Example for savings algorithm
- `run_two_opt_example()` - Example for 2-opt improvement
- `compare_vrp_heuristics()` - Compare all heuristics
- `demonstrate_hybrid_approach()` - Show hybrid methodology

## Extensions

The code can be easily extended to support:
- Time windows constraints
- Multiple depots
- Heterogeneous vehicle fleet
- Different distance metrics (Manhattan, etc.)
- Additional VRP variants
- Custom objective functions

## Performance Tips

- For large instances, consider increasing `max_iterations` parameters
- Use the hybrid approach for best solution quality
- Start with Clarke-Wright for better initial solutions
- Apply 2-opt improvement iteratively for continued refinement
