# API Reference

## Problem Definition Functions

### `generate_problem_instance()`

Generate a random problem instance for MDVRPTWH.

**Parameters:**
- `num_depots` (integer, default: 2): Number of depots
- `num_customers` (integer, default: 7): Number of customers
- `num_vehicles` (integer, default: 2): Number of vehicles
- `num_vehicle_types` (integer, default: 2): Number of different vehicle types
- `grid_size` (numeric, default: 100): Size of the coordinate grid
- `seed` (integer, default: 42): Random seed for reproducibility

**Returns:**
A list containing:
- `depots`: Data frame with depot information
- `customers`: Data frame with customer information
- `vehicles`: Data frame with vehicle information
- `vehicle_types`: Data frame with vehicle type definitions
- `distance_matrix`: Matrix of distances between all locations
- `time_matrix`: Matrix of travel times between all locations
- `all_locations`: Combined location data
- `parameters`: List of generation parameters

**Example:**
```r
problem <- generate_problem_instance(
  num_depots = 2,
  num_customers = 7,
  num_vehicles = 2,
  num_vehicle_types = 2
)
```

### `generate_problem_summary(problem)`

Generate a text summary of the problem instance.

**Parameters:**
- `problem`: A problem instance from `generate_problem_instance()`

**Returns:**
Character string with formatted problem summary

### `validate_problem_instance(problem)`

Validate a problem instance for correctness and feasibility.

**Parameters:**
- `problem`: A problem instance to validate

**Returns:**
List with:
- `valid` (logical): Whether the instance is valid
- `errors` (character vector): Error messages
- `warnings` (character vector): Warning messages

## Solver Functions

### `solve_mdvrptwh()`

Main solver function for MDVRPTWH.

**Parameters:**
- `problem`: A problem instance from `generate_problem_instance()`
- `method` (character, default: "nn"): Solving method
  - `"nn"`: Nearest Neighbor
  - `"greedy"`: Greedy Best Insertion
  - `"sa"`: Simulated Annealing
- `max_iterations` (integer, default: 1000): Maximum iterations for metaheuristics

**Returns:**
Solution object with:
- `routes`: List of route objects
- `cost`: Total solution cost
- `status`: Solution status ("OPTIMAL", "INFEASIBLE", "ERROR")
- `solve_time`: Computation time in seconds
- `method`: Algorithm used

**Example:**
```r
solution <- solve_mdvrptwh(
  problem = problem,
  method = "sa",
  max_iterations = 2000
)
```

### `solve_nearest_neighbor(problem)`

Nearest Neighbor algorithm implementation.

**Parameters:**
- `problem`: Problem instance

**Returns:**
Partial solution object with routes

### `solve_greedy(problem)`

Greedy Best Insertion algorithm implementation.

**Parameters:**
- `problem`: Problem instance

**Returns:**
Partial solution object with routes

### `solve_simulated_annealing(problem, max_iterations)`

Simulated Annealing algorithm implementation.

**Parameters:**
- `problem`: Problem instance
- `max_iterations`: Maximum number of iterations

**Returns:**
Partial solution object with routes

## Utility Functions

### `get_distance(problem, from_idx, to_idx)`

Get distance between two locations.

**Parameters:**
- `problem`: Problem instance
- `from_idx`: Index of origin location
- `to_idx`: Index of destination location

**Returns:**
Numeric distance value

### `calculate_total_cost(problem, routes)`

Calculate total cost of a solution.

**Parameters:**
- `problem`: Problem instance
- `routes`: List of route objects

**Returns:**
Numeric total cost

### `validate_solution(problem, solution)`

Validate if a solution is feasible.

**Parameters:**
- `problem`: Problem instance
- `solution`: Solution to validate

**Returns:**
Logical indicating feasibility

## Visualization Functions

### `generate_solution_summary(solution)`

Generate formatted text summary of solution.

**Parameters:**
- `solution`: Solution object

**Returns:**
Character string with solution details

### `format_routes_table(solution)`

Format routes for display in data table.

**Parameters:**
- `solution`: Solution object

**Returns:**
Data frame with route information

### `plot_routes(problem, solution)`

Create interactive plot of routes.

**Parameters:**
- `problem`: Problem instance
- `solution`: Solution object

**Returns:**
Plotly visualization object

### `plot_vehicle_utilization(solution)`

Create bar chart of vehicle utilization.

**Parameters:**
- `solution`: Solution object

**Returns:**
Plotly bar chart object

### `plot_time_windows(problem, solution)`

Create Gantt-style chart of time windows and service times.

**Parameters:**
- `problem`: Problem instance
- `solution`: Solution object

**Returns:**
Plotly chart object

## Data Structures

### Problem Instance Structure

```r
problem <- list(
  depots = data.frame(
    depot_id, x, y, name, capacity, open_time, close_time
  ),
  customers = data.frame(
    customer_id, x, y, demand, service_time, early_time, late_time, name
  ),
  vehicles = data.frame(
    vehicle_id, depot_id, type_id, type_name, capacity, speed, 
    fixed_cost, variable_cost, x_depot, y_depot
  ),
  vehicle_types = data.frame(
    type_id, type_name, capacity, speed, fixed_cost, variable_cost
  ),
  distance_matrix = matrix(...),
  time_matrix = matrix(...),
  all_locations = data.frame(...),
  parameters = list(...)
)
```

### Route Structure

```r
route <- list(
  vehicle_id = integer,
  depot_id = integer,
  sequence = integer vector,  # Location indices
  arrival_times = numeric vector,
  service_times = numeric vector,
  total_distance = numeric,
  total_time = numeric,
  load = numeric
)
```

### Solution Structure

```r
solution <- list(
  routes = list of route objects,
  cost = numeric,
  status = character,
  solve_time = numeric,
  method = character
)
```

## Error Handling

### Common Error Messages

- `"Invalid problem instance"`: Problem validation failed
- `"Unknown solving method"`: Invalid method parameter
- `"No feasible solution found"`: Constraints too restrictive

### Validation Checks

- All required data components present
- Time windows are consistent (late_time > early_time)
- Distance matrix dimensions match locations
- Vehicle capacities vs. customer demands
- Depot and customer coordinate validity

## Performance Considerations

### Algorithm Complexity
- Nearest Neighbor: O(n² × v)
- Greedy: O(n³ × v)  
- Simulated Annealing: O(iterations × neighborhood_size)

### Memory Usage
- Distance matrix: O(n²) where n = total locations
- Solution storage: O(routes × customers_per_route)

### Recommendations
- Use Nearest Neighbor for quick prototyping
- Use Greedy for balanced performance
- Use Simulated Annealing for best solution quality
- Limit iterations for large instances to control runtime