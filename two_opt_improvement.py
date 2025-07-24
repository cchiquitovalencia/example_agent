"""
2-opt Local Search Improvement Heuristic for Vehicle Routing Problem (VRP)

This improvement heuristic takes an existing VRP solution and applies 2-opt
moves to improve individual routes by removing two edges and reconnecting
the route in a different way.
"""

import math
import copy
from typing import List, Tuple, Dict


class TwoOptVRP:
    def __init__(self, depot: Tuple[float, float], customers: List[Tuple[float, float]], 
                 demands: List[int], vehicle_capacity: int):
        """
        Initialize the 2-opt VRP improvement heuristic.
        
        Args:
            depot: (x, y) coordinates of the depot
            customers: List of (x, y) coordinates for each customer
            demands: List of demands for each customer
            vehicle_capacity: Maximum capacity of each vehicle
        """
        self.depot = depot
        self.customers = customers
        self.demands = demands
        self.vehicle_capacity = vehicle_capacity
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
    
    def improve_solution(self, initial_routes: List[List[int]], 
                        max_iterations: int = 1000) -> Dict:
        """
        Improve an initial VRP solution using 2-opt local search.
        
        Args:
            initial_routes: List of routes, where each route is a list of customer indices
            max_iterations: Maximum number of iterations without improvement
            
        Returns:
            Dictionary containing improved routes and solution info
        """
        current_routes = copy.deepcopy(initial_routes)
        current_distance = self._calculate_total_distance(current_routes)
        
        improvement_found = True
        iterations_without_improvement = 0
        total_iterations = 0
        
        print(f"Initial solution distance: {current_distance:.2f}")
        
        while improvement_found and iterations_without_improvement < max_iterations:
            improvement_found = False
            total_iterations += 1
            
            # Try to improve each route
            for route_idx, route in enumerate(current_routes):
                if len(route) < 3:  # Need at least 3 customers for 2-opt
                    continue
                
                improved_route, improvement = self._improve_route_2opt(route)
                
                if improvement > 0.001:  # Significant improvement threshold
                    current_routes[route_idx] = improved_route
                    current_distance -= improvement
                    improvement_found = True
                    iterations_without_improvement = 0
                    print(f"Iteration {total_iterations}: Route {route_idx+1} improved by {improvement:.2f}")
                    break  # Restart from the beginning after an improvement
            
            if not improvement_found:
                iterations_without_improvement += 1
        
        print(f"Final solution distance: {current_distance:.2f}")
        print(f"Total iterations: {total_iterations}")
        
        return {
            'routes': current_routes,
            'total_distance': current_distance,
            'num_vehicles_used': len(current_routes),
            'improvement_iterations': total_iterations,
            'feasible': self._check_feasibility(current_routes)
        }
    
    def _improve_route_2opt(self, route: List[int]) -> Tuple[List[int], float]:
        """
        Improve a single route using 2-opt moves.
        
        Args:
            route: List of customer indices representing the route
            
        Returns:
            Tuple of (improved_route, improvement_amount)
        """
        best_route = route.copy()
        best_distance = self._calculate_route_distance(route)
        best_improvement = 0.0
        
        n = len(route)
        
        # Try all possible 2-opt moves
        for i in range(n - 1):
            for j in range(i + 2, n):
                # Create new route by reversing the segment between i+1 and j
                new_route = route.copy()
                new_route[i+1:j+1] = reversed(new_route[i+1:j+1])
                
                # Check if the new route is feasible (capacity constraint)
                if not self._is_route_feasible(new_route):
                    continue
                
                new_distance = self._calculate_route_distance(new_route)
                improvement = best_distance - new_distance
                
                if improvement > best_improvement:
                    best_route = new_route
                    best_improvement = improvement
        
        return best_route, best_improvement
    
    def _calculate_route_distance(self, route: List[int]) -> float:
        """Calculate the total distance for a route."""
        if not route:
            return 0.0
        
        distance = 0.0
        
        # Depot to first customer
        distance += self.distance_matrix[0][route[0] + 1]
        
        # Between customers
        for i in range(len(route) - 1):
            distance += self.distance_matrix[route[i] + 1][route[i + 1] + 1]
        
        # Last customer to depot
        distance += self.distance_matrix[route[-1] + 1][0]
        
        return distance
    
    def _calculate_total_distance(self, routes: List[List[int]]) -> float:
        """Calculate the total distance for all routes."""
        return sum(self._calculate_route_distance(route) for route in routes)
    
    def _is_route_feasible(self, route: List[int]) -> bool:
        """Check if a route satisfies the capacity constraint."""
        total_demand = sum(self.demands[customer] for customer in route)
        return total_demand <= self.vehicle_capacity
    
    def _check_feasibility(self, routes: List[List[int]]) -> bool:
        """Check if all routes are feasible."""
        return all(self._is_route_feasible(route) for route in routes)
    
    def get_route_info(self, route: List[int]) -> Dict:
        """Get detailed information about a specific route."""
        if not route:
            return {'distance': 0, 'load': 0, 'customers': []}
        
        total_load = sum(self.demands[customer] for customer in route)
        distance = self._calculate_route_distance(route)
        
        return {
            'distance': distance,
            'load': total_load,
            'customers': route,
            'capacity_utilization': total_load / self.vehicle_capacity,
            'feasible': self._is_route_feasible(route)
        }
    
    def inter_route_2opt(self, routes: List[List[int]], max_iterations: int = 500) -> Dict:
        """
        Apply 2-opt moves between different routes (inter-route optimization).
        
        Args:
            routes: List of routes to optimize
            max_iterations: Maximum iterations without improvement
            
        Returns:
            Dictionary containing improved routes and solution info
        """
        current_routes = copy.deepcopy(routes)
        current_distance = self._calculate_total_distance(current_routes)
        
        improvement_found = True
        iterations_without_improvement = 0
        total_iterations = 0
        
        print(f"Starting inter-route 2-opt with distance: {current_distance:.2f}")
        
        while improvement_found and iterations_without_improvement < max_iterations:
            improvement_found = False
            total_iterations += 1
            
            # Try swapping customers between different routes
            for i in range(len(current_routes)):
                for j in range(i + 1, len(current_routes)):
                    if not current_routes[i] or not current_routes[j]:
                        continue
                    
                    # Try swapping each customer from route i with each customer from route j
                    for ci in range(len(current_routes[i])):
                        for cj in range(len(current_routes[j])):
                            # Create new routes with swapped customers
                            new_route_i = current_routes[i].copy()
                            new_route_j = current_routes[j].copy()
                            
                            # Swap customers
                            new_route_i[ci], new_route_j[cj] = new_route_j[cj], new_route_i[ci]
                            
                            # Check feasibility
                            if (self._is_route_feasible(new_route_i) and 
                                self._is_route_feasible(new_route_j)):
                                
                                # Calculate improvement
                                old_distance = (self._calculate_route_distance(current_routes[i]) + 
                                              self._calculate_route_distance(current_routes[j]))
                                new_distance = (self._calculate_route_distance(new_route_i) + 
                                              self._calculate_route_distance(new_route_j))
                                
                                if new_distance < old_distance - 0.001:  # Improvement threshold
                                    improvement = old_distance - new_distance
                                    current_routes[i] = new_route_i
                                    current_routes[j] = new_route_j
                                    current_distance -= improvement
                                    improvement_found = True
                                    iterations_without_improvement = 0
                                    print(f"Inter-route iteration {total_iterations}: "
                                          f"Swapped customers between routes {i+1} and {j+1}, "
                                          f"improvement: {improvement:.2f}")
                                    break
                        if improvement_found:
                            break
                    if improvement_found:
                        break
                if improvement_found:
                    break
            
            if not improvement_found:
                iterations_without_improvement += 1
        
        print(f"Final inter-route distance: {current_distance:.2f}")
        
        return {
            'routes': current_routes,
            'total_distance': current_distance,
            'num_vehicles_used': len(current_routes),
            'improvement_iterations': total_iterations,
            'feasible': self._check_feasibility(current_routes)
        }


def main():
    """Example usage of the 2-opt improvement heuristic."""
    # Example problem instance
    depot = (0, 0)
    customers = [(4, 4), (6, 2), (8, 6), (2, 8), (10, 4), (12, 2)]
    demands = [3, 5, 2, 4, 6, 3]
    vehicle_capacity = 10
    
    # Initial solution (could come from nearest neighbor or savings algorithm)
    initial_routes = [
        [0, 2, 3],  # Vehicle 1: customers 0, 2, 3
        [1, 4],     # Vehicle 2: customers 1, 4  
        [5]         # Vehicle 3: customer 5
    ]
    
    # Initialize 2-opt solver
    solver = TwoOptVRP(depot, customers, demands, vehicle_capacity)
    
    print("=== 2-opt VRP Improvement ===")
    
    # Print initial solution
    print("\nInitial Solution:")
    initial_distance = solver._calculate_total_distance(initial_routes)
    print(f"Total Distance: {initial_distance:.2f}")
    
    for i, route in enumerate(initial_routes):
        route_info = solver.get_route_info(route)
        print(f"Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"  Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity}")
    
    # Apply intra-route 2-opt improvement
    print("\n--- Applying Intra-route 2-opt ---")
    improved_solution = solver.improve_solution(initial_routes, max_iterations=100)
    
    print(f"\nImproved Solution (Intra-route):")
    print(f"Total Distance: {improved_solution['total_distance']:.2f}")
    print(f"Improvement: {initial_distance - improved_solution['total_distance']:.2f}")
    
    for i, route in enumerate(improved_solution['routes']):
        route_info = solver.get_route_info(route)
        print(f"Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"  Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity}")
    
    # Apply inter-route 2-opt improvement
    print("\n--- Applying Inter-route 2-opt ---")
    final_solution = solver.inter_route_2opt(improved_solution['routes'], max_iterations=100)
    
    print(f"\nFinal Solution (Inter-route):")
    print(f"Total Distance: {final_solution['total_distance']:.2f}")
    print(f"Total Improvement: {initial_distance - final_solution['total_distance']:.2f}")
    
    for i, route in enumerate(final_solution['routes']):
        route_info = solver.get_route_info(route)
        print(f"Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"  Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity}")


if __name__ == "__main__":
    main()