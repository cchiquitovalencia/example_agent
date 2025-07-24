# Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet (MDVRPTWH)

## Problem Overview

The Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet (MDVRPTWH) is a complex optimization problem that extends the classical Vehicle Routing Problem (VRP) to include multiple depots, time window constraints, and different vehicle types.

## Problem Definition

### Objective
Find the minimum-cost set of routes for a heterogeneous fleet of vehicles based at multiple depots to serve a set of customers, subject to:
- **Capacity constraints**: Each vehicle has a maximum capacity
- **Time window constraints**: Each customer must be served within a specified time window
- **Depot constraints**: Vehicles must start and end at their assigned depot
- **Vehicle type constraints**: Different vehicle types have different capacities, speeds, and costs

### Mathematical Formulation

**Given:**
- Set of depots: D = {1, 2, ..., m}
- Set of customers: C = {1, 2, ..., n}
- Set of vehicle types: T = {1, 2, ..., t}
- Set of vehicles: V = {1, 2, ..., v}

**Parameters:**
- `d_ij`: Distance between locations i and j
- `t_ij`: Travel time between locations i and j
- `q_i`: Demand of customer i
- `[e_i, l_i]`: Time window for customer i
- `s_i`: Service time at customer i
- `Q_k`: Capacity of vehicle k
- `f_k`: Fixed cost of using vehicle k
- `c_k`: Variable cost per unit distance for vehicle k

**Decision Variables:**
- `x_ijk`: Binary variable = 1 if vehicle k travels from i to j, 0 otherwise
- `y_ik`: Binary variable = 1 if customer i is served by vehicle k, 0 otherwise
- `t_ik`: Time at which vehicle k starts service at customer i

### Constraints

1. **Customer service**: Each customer must be served exactly once
2. **Vehicle capacity**: Total demand on each route ≤ vehicle capacity
3. **Time windows**: Service must start within customer time windows
4. **Route continuity**: Vehicles must form connected routes
5. **Depot constraints**: Vehicles start and end at their assigned depot

## Problem Instance Structure

### Depots
- Location coordinates (x, y)
- Operating hours (open_time, close_time)
- Capacity (if applicable)

### Customers
- Location coordinates (x, y)
- Demand quantity
- Time window [early_time, late_time]
- Service time duration

### Vehicle Types
- Capacity
- Speed
- Fixed cost (for using the vehicle)
- Variable cost (per unit distance)

### Vehicles
- Assigned depot
- Vehicle type
- Individual characteristics inherited from type

## Solution Representation

A solution consists of a set of routes, where each route:
- Is assigned to a specific vehicle
- Starts and ends at the vehicle's depot
- Visits a subset of customers
- Respects all constraints
- Has calculated metrics (distance, time, cost, load)

## Problem Complexity

The MDVRPTWH is NP-hard, meaning that:
- No polynomial-time algorithm is known for finding optimal solutions
- The problem size grows exponentially with the number of customers
- Heuristic and metaheuristic approaches are typically used for practical instances

## Applications

1. **Logistics and Distribution**
   - Package delivery services
   - Food distribution
   - Pharmaceutical supply chains

2. **Service Industries**
   - Home healthcare
   - Field service management
   - Maintenance operations

3. **Public Services**
   - Waste collection
   - Public transportation
   - Emergency services

## Typical Instance Sizes

- **Small instances**: 5-20 customers, 2-3 depots, 2-5 vehicles
- **Medium instances**: 20-100 customers, 3-5 depots, 5-20 vehicles  
- **Large instances**: 100+ customers, 5+ depots, 20+ vehicles

This application focuses on small instances for demonstration and educational purposes.