# Algorithm Documentation

## Overview

This application implements three different algorithms to solve the MDVRPTWH problem. Each algorithm has different characteristics in terms of solution quality, computational time, and complexity.

## 1. Nearest Neighbor Algorithm (NN)

### Description
The Nearest Neighbor algorithm is a simple greedy constructive heuristic that builds routes by iteratively selecting the closest feasible customer to the current location.

### Algorithm Steps
1. For each vehicle:
   - Start at the assigned depot
   - While there are unvisited customers and vehicle capacity allows:
     - Find the nearest customer that:
       - Can be served within capacity constraints
       - Can be reached within its time window
     - Add the customer to the route
     - Update current location, time, and remaining capacity
   - Return to the depot

### Characteristics
- **Time Complexity**: O(n² × v) where n = customers, v = vehicles
- **Solution Quality**: Generally poor, but fast to compute
- **Advantages**: Simple, fast, provides feasible solutions
- **Disadvantages**: Often produces suboptimal solutions due to greedy nature

### When to Use
- Quick initial solutions
- Real-time applications requiring fast responses
- Baseline for comparison with other algorithms

## 2. Greedy Best Insertion Algorithm

### Description
The Greedy Best Insertion algorithm builds routes by iteratively inserting customers at the position that minimizes the cost increase.

### Algorithm Steps
1. For each vehicle:
   - Initialize route with depot → depot
   - While there are unvisited customers:
     - For each unvisited customer:
       - Find the best insertion position that minimizes cost increase
       - Check feasibility (capacity, time windows)
     - Insert the customer with minimum cost increase
     - Update route metrics

### Cost Calculation
The insertion cost considers:
- Distance increase from inserting customer at position
- Time window feasibility
- Vehicle-specific costs (variable cost per distance)

### Characteristics
- **Time Complexity**: O(n³ × v)
- **Solution Quality**: Better than Nearest Neighbor
- **Advantages**: Considers global route structure, better optimization
- **Disadvantages**: More computationally expensive than NN

### When to Use
- When solution quality is more important than speed
- As initialization for metaheuristics
- Medium-sized problem instances

## 3. Simulated Annealing (SA)

### Description
Simulated Annealing is a metaheuristic that improves an initial solution through iterative local search with probabilistic acceptance of worse solutions to escape local optima.

### Algorithm Steps
1. Generate initial solution using Greedy algorithm
2. Set initial temperature T₀
3. For each iteration:
   - Generate neighbor solution through local search operators
   - Calculate cost difference Δ
   - Accept neighbor if:
     - Δ < 0 (improvement), or
     - Random probability < exp(-Δ/T) (worse solution acceptance)
   - Update current solution if accepted
   - Cool down temperature: T = T × α

### Neighborhood Operators
- **Swap**: Exchange customers between two routes
- **Relocate**: Move customer from one route to another
- **2-opt**: Reverse segment within a route

### Parameters
- **Initial Temperature**: 10% of initial solution cost
- **Final Temperature**: 0.01
- **Cooling Rate**: Geometric cooling
- **Iterations**: User-configurable (default: 1000)

### Characteristics
- **Time Complexity**: O(iterations × neighborhood_size)
- **Solution Quality**: Best among the three algorithms
- **Advantages**: Can escape local optima, produces high-quality solutions
- **Disadvantages**: Computationally expensive, requires parameter tuning

### When to Use
- When high solution quality is required
- Sufficient computational time is available
- Complex problem instances with many constraints

## Algorithm Comparison

| Algorithm | Speed | Quality | Complexity | Best Use Case |
|-----------|-------|---------|------------|---------------|
| Nearest Neighbor | ⭐⭐⭐ | ⭐ | Low | Quick baseline |
| Greedy Insertion | ⭐⭐ | ⭐⭐ | Medium | Balanced approach |
| Simulated Annealing | ⭐ | ⭐⭐⭐ | High | High-quality solutions |

## Implementation Details

### Constraint Handling
All algorithms handle:
- **Capacity constraints**: Check vehicle load before adding customers
- **Time window constraints**: Verify arrival times and service windows
- **Depot constraints**: Ensure routes start/end at correct depot

### Solution Validation
Each solution is validated for:
- Feasibility of all constraints
- Route connectivity
- Customer coverage (when possible)

### Cost Calculation
Total cost includes:
- Fixed cost for each used vehicle
- Variable cost based on total distance traveled
- Penalty for constraint violations (if applicable)

## Future Enhancements

Potential improvements to the algorithms:
1. **Advanced operators** for Simulated Annealing (Or-opt, cross-exchange)
2. **Adaptive parameters** for temperature scheduling
3. **Hybrid approaches** combining multiple algorithms
4. **Parallel processing** for independent route construction
5. **Machine learning** for parameter tuning