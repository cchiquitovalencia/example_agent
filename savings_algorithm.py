"""
Clarke-Wright Savings Algorithm for Vehicle Routing Problem (VRP)

This classical heuristic starts with individual routes from depot to each customer
and then combines routes based on savings calculations to minimize total distance.
"""

import math
from typing import List, Tuple, Dict, Set
from operator import itemgetter


class SavingsAlgorithmVRP:
    def __init__(self, depot: Tuple[float, float], customers: List[Tuple[float, float]], 
                 demands: List[int], vehicle_capacity: int, num_vehicles: int):
        """
        Initialize the Clarke-Wright Savings Algorithm VRP solver.
        
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
        
        # Calculate savings for all customer pairs
        self.savings_list = self._calculate_savings()
    
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
    
    def _calculate_savings(self) -> List[Tuple[int, int, float]]:
        """
        Calculate savings for all customer pairs.
        
        Savings(i,j) = distance(depot,i) + distance(depot,j) - distance(i,j)
        
        Returns:
            List of tuples (customer_i, customer_j, savings_value) sorted by savings
        """
        savings = []
        
        for i in range(self.num_customers):
            for j in range(i + 1, self.num_customers):
                # Savings = d(0,i) + d(0,j) - d(i,j)
                # In distance matrix: depot=0, customer_i=i+1, customer_j=j+1
                depot_to_i = self.distance_matrix[0][i + 1]
                depot_to_j = self.distance_matrix[0][j + 1]
                i_to_j = self.distance_matrix[i + 1][j + 1]
                
                savings_value = depot_to_i + depot_to_j - i_to_j
                savings.append((i, j, savings_value))
        
        # Sort by savings in descending order
        savings.sort(key=itemgetter(2), reverse=True)
        return savings
    
    def solve(self) -> Dict:
        """
        Solve VRP using Clarke-Wright Savings Algorithm.
        
        Returns:
            Dictionary containing routes, total distance, and solution info
        """
        # Initialize: each customer is in its own route
        routes = [[i] for i in range(self.num_customers)]
        route_loads = [self.demands[i] for i in range(self.num_customers)]
        
        # Keep track of which route each customer belongs to
        customer_to_route = {i: i for i in range(self.num_customers)}
        
        # Process savings in decreasing order
        for customer_i, customer_j, savings_value in self.savings_list:
            if savings_value <= 0:
                break  # No more positive savings
            
            route_i = customer_to_route[customer_i]
            route_j = customer_to_route[customer_j]
            
            # Skip if customers are already in the same route
            if route_i == route_j:
                continue
            
            # Check if routes can be merged
            if self._can_merge_routes(routes[route_i], routes[route_j], 
                                    route_loads[route_i], route_loads[route_j],
                                    customer_i, customer_j):
                
                # Merge routes
                merged_route, merged_load = self._merge_routes(
                    routes[route_i], routes[route_j], customer_i, customer_j
                )
                
                # Update data structures
                routes[route_i] = merged_route
                route_loads[route_i] = merged_load
                
                # Update customer-to-route mapping for all customers in route_j
                for customer in routes[route_j]:
                    customer_to_route[customer] = route_i
                
                # Mark route_j as empty
                routes[route_j] = []
                route_loads[route_j] = 0
        
        # Remove empty routes and calculate total distance
        final_routes = [route for route in routes if route]
        
        # Check vehicle limit
        if len(final_routes) > self.num_vehicles:
            # Sort routes by load and keep only the best ones
            route_info = [(route, self._calculate_route_distance(route)) 
                         for route in final_routes]
            route_info.sort(key=itemgetter(1))  # Sort by distance
            final_routes = [route for route, _ in route_info[:self.num_vehicles]]
        
        total_distance = sum(self._calculate_route_distance(route) for route in final_routes)
        
        # Check which customers are served
        served_customers = set()
        for route in final_routes:
            served_customers.update(route)
        unvisited = [i for i in range(self.num_customers) if i not in served_customers]
        
        return {
            'routes': final_routes,
            'total_distance': total_distance,
            'num_vehicles_used': len(final_routes),
            'unvisited_customers': unvisited,
            'feasible': len(unvisited) == 0
        }
    
    def _can_merge_routes(self, route1: List[int], route2: List[int], 
                         load1: int, load2: int, customer_i: int, customer_j: int) -> bool:
        """
        Check if two routes can be merged.
        
        Routes can be merged if:
        1. Combined load doesn't exceed vehicle capacity
        2. customer_i and customer_j are at the ends of their respective routes
        """
        # Check capacity constraint
        if load1 + load2 > self.vehicle_capacity:
            return False
        
        # Check if customers are at the ends of their routes
        # customer_i must be at the beginning or end of route1
        # customer_j must be at the beginning or end of route2
        i_at_end = (route1[0] == customer_i or route1[-1] == customer_i)
        j_at_end = (route2[0] == customer_j or route2[-1] == customer_j)
        
        return i_at_end and j_at_end
    
    def _merge_routes(self, route1: List[int], route2: List[int], 
                     customer_i: int, customer_j: int) -> Tuple[List[int], int]:
        """
        Merge two routes connecting customer_i and customer_j.
        
        Returns:
            Tuple of (merged_route, merged_load)
        """
        # Determine the order of merging based on positions of customers
        merged_route = []
        
        # Find positions of customers in their routes
        i_pos = 0 if route1[0] == customer_i else len(route1) - 1
        j_pos = 0 if route2[0] == customer_j else len(route2) - 1
        
        if i_pos == len(route1) - 1 and j_pos == 0:
            # customer_i is at end of route1, customer_j is at start of route2
            merged_route = route1 + route2
        elif i_pos == 0 and j_pos == len(route2) - 1:
            # customer_i is at start of route1, customer_j is at end of route2
            merged_route = route2 + route1
        elif i_pos == len(route1) - 1 and j_pos == len(route2) - 1:
            # Both at the end - reverse route2 and append
            merged_route = route1 + route2[::-1]
        elif i_pos == 0 and j_pos == 0:
            # Both at the beginning - reverse route1 and append route2
            merged_route = route1[::-1] + route2
        
        merged_load = sum(self.demands[customer] for customer in merged_route)
        
        return merged_route, merged_load
    
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
            'capacity_utilization': total_load / self.vehicle_capacity
        }


def main():
    """Example usage of the Clarke-Wright Savings Algorithm."""
    # Example problem instance
    depot = (0, 0)
    customers = [(4, 4), (6, 2), (8, 6), (2, 8), (10, 4), (12, 2)]
    demands = [3, 5, 2, 4, 6, 3]
    vehicle_capacity = 10
    num_vehicles = 3
    
    # Solve the problem
    solver = SavingsAlgorithmVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    solution = solver.solve()
    
    # Print results
    print("=== Clarke-Wright Savings Algorithm VRP Solution ===")
    print(f"Total Distance: {solution['total_distance']:.2f}")
    print(f"Vehicles Used: {solution['num_vehicles_used']}/{num_vehicles}")
    print(f"Feasible Solution: {solution['feasible']}")
    
    # Print savings information
    print(f"\nTop 5 Savings:")
    for i, (cust_i, cust_j, savings) in enumerate(solver.savings_list[:5]):
        print(f"  {i+1}. Customers {cust_i}-{cust_j}: Savings = {savings:.2f}")
    
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