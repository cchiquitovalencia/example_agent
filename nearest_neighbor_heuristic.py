"""
Nearest Neighbor Heuristic for Vehicle Routing Problem (VRP)

This heuristic constructs routes by starting from the depot and repeatedly
selecting the nearest unvisited customer until vehicle capacity is reached
or all customers are served.
"""

import math
from typing import List, Tuple, Dict


class NearestNeighborVRP:
    def __init__(self, depot: Tuple[float, float], customers: List[Tuple[float, float]], 
                 demands: List[int], vehicle_capacity: int, num_vehicles: int):
        """
        Initialize the Nearest Neighbor VRP solver.
        
        Args:
            depot: (x, y) coordinates of the depot
            customers: List of (x, y) coordinates for each customer
            demands: List of demands for each customer
            vehicle_capacity: Maximum capacity of each vehicle
            num_vehicles: Number of available vehicles
        """
        self.depot = depot
        self.customers = customers
        self.demands = demands
        self.vehicle_capacity = vehicle_capacity
        self.num_vehicles = num_vehicles
        self.num_customers = len(customers)
        
        # Precompute distance matrix
        self.distance_matrix = self._compute_distance_matrix()
    
    def _compute_distance_matrix(self) -> List[List[float]]:
        """Compute the distance matrix between all points (depot + customers)."""
        points = [self.depot] + self.customers
        n = len(points)
        matrix = [[0.0] * n for _ in range(n)]
        
        for i in range(n):
            for j in range(n):
                if i != j:
                    matrix[i][j] = self._euclidean_distance(points[i], points[j])
        
        return matrix
    
    def _euclidean_distance(self, point1: Tuple[float, float], 
                          point2: Tuple[float, float]) -> float:
        """Calculate Euclidean distance between two points."""
        return math.sqrt((point1[0] - point2[0])**2 + (point1[1] - point2[1])**2)
    
    def solve(self) -> Dict:
        """
        Solve VRP using Nearest Neighbor heuristic.
        
        Returns:
            Dictionary containing routes, total distance, and solution info
        """
        unvisited = set(range(self.num_customers))
        routes = []
        total_distance = 0.0
        
        vehicle_count = 0
        
        while unvisited and vehicle_count < self.num_vehicles:
            route, route_distance = self._construct_route(unvisited)
            if route:  # Only add non-empty routes
                routes.append(route)
                total_distance += route_distance
                vehicle_count += 1
            else:
                break  # No more feasible routes
        
        return {
            'routes': routes,
            'total_distance': total_distance,
            'num_vehicles_used': len(routes),
            'unvisited_customers': list(unvisited),
            'feasible': len(unvisited) == 0
        }
    
    def _construct_route(self, unvisited: set) -> Tuple[List[int], float]:
        """
        Construct a single route using nearest neighbor heuristic.
        
        Args:
            unvisited: Set of unvisited customer indices
            
        Returns:
            Tuple of (route, route_distance)
        """
        if not unvisited:
            return [], 0.0
        
        route = []
        current_load = 0
        current_position = 0  # Start at depot (index 0)
        route_distance = 0.0
        
        while unvisited:
            # Find nearest feasible customer
            nearest_customer = None
            nearest_distance = float('inf')
            
            for customer_idx in unvisited:
                # Check capacity constraint
                if current_load + self.demands[customer_idx] <= self.vehicle_capacity:
                    # Distance from current position to customer (customer_idx + 1 in matrix)
                    distance = self.distance_matrix[current_position][customer_idx + 1]
                    if distance < nearest_distance:
                        nearest_distance = distance
                        nearest_customer = customer_idx
            
            if nearest_customer is None:
                # No feasible customer found
                break
            
            # Add customer to route
            route.append(nearest_customer)
            unvisited.remove(nearest_customer)
            current_load += self.demands[nearest_customer]
            route_distance += nearest_distance
            current_position = nearest_customer + 1  # Update position in distance matrix
        
        # Return to depot
        if route:
            route_distance += self.distance_matrix[current_position][0]
        
        return route, route_distance
    
    def get_route_info(self, route: List[int]) -> Dict:
        """Get detailed information about a specific route."""
        if not route:
            return {'distance': 0, 'load': 0, 'customers': []}
        
        total_load = sum(self.demands[customer] for customer in route)
        
        # Calculate route distance
        distance = self.distance_matrix[0][route[0] + 1]  # Depot to first customer
        for i in range(len(route) - 1):
            distance += self.distance_matrix[route[i] + 1][route[i + 1] + 1]
        distance += self.distance_matrix[route[-1] + 1][0]  # Last customer to depot
        
        return {
            'distance': distance,
            'load': total_load,
            'customers': route,
            'capacity_utilization': total_load / self.vehicle_capacity
        }


def main():
    """Example usage of the Nearest Neighbor VRP heuristic."""
    # Example problem instance
    depot = (0, 0)
    customers = [(4, 4), (6, 2), (8, 6), (2, 8), (10, 4), (12, 2)]
    demands = [3, 5, 2, 4, 6, 3]
    vehicle_capacity = 10
    num_vehicles = 3
    
    # Solve the problem
    solver = NearestNeighborVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    solution = solver.solve()
    
    # Print results
    print("=== Nearest Neighbor VRP Solution ===")
    print(f"Total Distance: {solution['total_distance']:.2f}")
    print(f"Vehicles Used: {solution['num_vehicles_used']}/{num_vehicles}")
    print(f"Feasible Solution: {solution['feasible']}")
    
    for i, route in enumerate(solution['routes']):
        route_info = solver.get_route_info(route)
        print(f"\nVehicle {i+1}:")
        print(f"  Route: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"  Distance: {route_info['distance']:.2f}")
        print(f"  Load: {route_info['load']}/{vehicle_capacity}")
        print(f"  Capacity Utilization: {route_info['capacity_utilization']:.1%}")
    
    if solution['unvisited_customers']:
        print(f"\nUnvisited customers: {solution['unvisited_customers']}")


if __name__ == "__main__":
    main()