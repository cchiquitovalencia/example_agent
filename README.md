# Vehicle Routing Problem (VRP) Heuristics

This repository contains implementations of three different heuristics for solving the Vehicle Routing Problem (VRP):

1. **Nearest Neighbor Heuristic** - A constructive greedy algorithm
2. **Clarke-Wright Savings Algorithm** - A classical VRP constructive heuristic  
3. **2-opt Local Search** - An improvement heuristic for route optimization

## Files Description

- `nearest_neighbor_heuristic.py` - Nearest Neighbor implementation
- `savings_algorithm.py` - Clarke-Wright Savings Algorithm implementation
- `two_opt_improvement.py` - 2-opt local search improvement heuristic
- `vrp_example.py` - Example script demonstrating all heuristics and comparisons

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

```python
# Nearest Neighbor
from nearest_neighbor_heuristic import NearestNeighborVRP

depot = (0, 0)
customers = [(4, 4), (6, 2), (8, 6)]
demands = [3, 5, 2]
vehicle_capacity = 10
num_vehicles = 2

solver = NearestNeighborVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
solution = solver.solve()
```

```python
# Clarke-Wright Savings
from savings_algorithm import SavingsAlgorithmVRP

solver = SavingsAlgorithmVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
solution = solver.solve()
```

```python
# 2-opt Improvement
from two_opt_improvement import TwoOptVRP

initial_routes = [[0, 1], [2]]  # Initial solution
solver = TwoOptVRP(depot, customers, demands, vehicle_capacity)
improved_solution = solver.improve_solution(initial_routes)
```

### Running Comprehensive Example

```bash
python vrp_example.py
```

This will:
- Compare all three heuristics on the same problem
- Show performance metrics and solution quality
- Demonstrate a hybrid approach combining multiple methods
- Provide detailed analysis and recommendations

## Solution Format

All heuristics return solutions in the same format:

```python
{
    'routes': [[0, 2], [1, 3]],  # List of routes (customer indices)
    'total_distance': 25.4,      # Total travel distance
    'num_vehicles_used': 2,      # Number of vehicles used
    'unvisited_customers': [],   # Customers not served (if any)
    'feasible': True             # Whether solution is feasible
}
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
Feasible: True

=== Clarke-Wright Savings ===
Total Distance: 42.17
Vehicles Used: 3
Feasible: True

=== Hybrid Approach ===
Initial (Clarke-Wright): 42.17
After intra-route 2-opt: 40.85
After inter-route 2-opt: 39.92
Total improvement: 2.25
```

## Extensions

The code can be easily extended to support:
- Time windows constraints
- Multiple depots
- Heterogeneous vehicle fleet
- Different distance metrics
- Additional VRP variants
