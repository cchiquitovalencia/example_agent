"""
Example demonstrating the use of three VRP heuristics:
1. Nearest Neighbor Heuristic (constructive)
2. Clarke-Wright Savings Algorithm (constructive)
3. 2-opt Local Search (improvement)

This script compares the performance of different approaches and shows
how to combine constructive and improvement heuristics.
"""

import time
from nearest_neighbor_heuristic import NearestNeighborVRP
from savings_algorithm import SavingsAlgorithmVRP
from two_opt_improvement import TwoOptVRP


def print_solution_summary(name: str, solution: dict, solve_time: float):
    """Print a summary of the solution."""
    print(f"\n=== {name} ===")
    print(f"Total Distance: {solution['total_distance']:.2f}")
    print(f"Vehicles Used: {solution['num_vehicles_used']}")
    print(f"Feasible: {solution['feasible']}")
    print(f"Solve Time: {solve_time:.4f} seconds")
    
    if solution['unvisited_customers']:
        print(f"Unvisited customers: {solution['unvisited_customers']}")


def compare_vrp_heuristics():
    """Compare different VRP heuristics on the same problem instance."""
    
    # Problem instance
    depot = (0, 0)
    customers = [
        (4, 4), (6, 2), (8, 6), (2, 8), (10, 4), (12, 2),
        (14, 6), (3, 1), (9, 9), (11, 8), (1, 5), (13, 3)
    ]
    demands = [3, 5, 2, 4, 6, 3, 4, 2, 5, 3, 4, 2]
    vehicle_capacity = 15
    num_vehicles = 4
    
    print("Vehicle Routing Problem - Heuristics Comparison")
    print("=" * 50)
    print(f"Number of customers: {len(customers)}")
    print(f"Vehicle capacity: {vehicle_capacity}")
    print(f"Number of vehicles: {num_vehicles}")
    print(f"Total demand: {sum(demands)}")
    
    # 1. Nearest Neighbor Heuristic
    print("\n" + "="*50)
    print("1. NEAREST NEIGHBOR HEURISTIC")
    print("="*50)
    
    start_time = time.time()
    nn_solver = NearestNeighborVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    nn_solution = nn_solver.solve()
    nn_time = time.time() - start_time
    
    print_solution_summary("Nearest Neighbor", nn_solution, nn_time)
    
    # Print detailed routes
    for i, route in enumerate(nn_solution['routes']):
        route_info = nn_solver.get_route_info(route)
        print(f"  Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"    Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity}")
    
    # 2. Clarke-Wright Savings Algorithm
    print("\n" + "="*50)
    print("2. CLARKE-WRIGHT SAVINGS ALGORITHM")
    print("="*50)
    
    start_time = time.time()
    cw_solver = SavingsAlgorithmVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    cw_solution = cw_solver.solve()
    cw_time = time.time() - start_time
    
    print_solution_summary("Clarke-Wright Savings", cw_solution, cw_time)
    
    # Print top savings
    print(f"\nTop 5 Savings computed:")
    for i, (cust_i, cust_j, savings) in enumerate(cw_solver.savings_list[:5]):
        print(f"  {i+1}. Customers {cust_i}-{cust_j}: Savings = {savings:.2f}")
    
    # Print detailed routes
    for i, route in enumerate(cw_solution['routes']):
        route_info = cw_solver.get_route_info(route)
        print(f"  Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"    Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity}")
    
    # 3. Improve solutions with 2-opt
    print("\n" + "="*50)
    print("3. 2-OPT IMPROVEMENT")
    print("="*50)
    
    # Improve Nearest Neighbor solution
    print("\nImproving Nearest Neighbor solution with 2-opt:")
    if nn_solution['routes']:
        start_time = time.time()
        opt_solver = TwoOptVRP(depot, customers, demands, vehicle_capacity)
        improved_nn = opt_solver.improve_solution(nn_solution['routes'], max_iterations=100)
        opt_time = time.time() - start_time
        
        print(f"Original NN distance: {nn_solution['total_distance']:.2f}")
        print(f"Improved distance: {improved_nn['total_distance']:.2f}")
        print(f"Improvement: {nn_solution['total_distance'] - improved_nn['total_distance']:.2f}")
        print(f"Improvement time: {opt_time:.4f} seconds")
    else:
        print("No routes to improve in Nearest Neighbor solution")
    
    # Improve Clarke-Wright solution
    print("\nImproving Clarke-Wright solution with 2-opt:")
    if cw_solution['routes']:
        start_time = time.time()
        improved_cw = opt_solver.improve_solution(cw_solution['routes'], max_iterations=100)
        opt_time = time.time() - start_time
        
        print(f"Original CW distance: {cw_solution['total_distance']:.2f}")
        print(f"Improved distance: {improved_cw['total_distance']:.2f}")
        print(f"Improvement: {cw_solution['total_distance'] - improved_cw['total_distance']:.2f}")
        print(f"Improvement time: {opt_time:.4f} seconds")
    else:
        print("No routes to improve in Clarke-Wright solution")
    
    # Summary comparison
    print("\n" + "="*50)
    print("FINAL COMPARISON")
    print("="*50)
    
    results = []
    if nn_solution['feasible']:
        final_nn_distance = improved_nn['total_distance'] if 'improved_nn' in locals() else nn_solution['total_distance']
        results.append(("Nearest Neighbor (+ 2-opt)", final_nn_distance, nn_solution['num_vehicles_used']))
    
    if cw_solution['feasible']:
        final_cw_distance = improved_cw['total_distance'] if 'improved_cw' in locals() else cw_solution['total_distance']
        results.append(("Clarke-Wright (+ 2-opt)", final_cw_distance, cw_solution['num_vehicles_used']))
    
    if results:
        results.sort(key=lambda x: x[1])  # Sort by distance
        print("Ranking by total distance:")
        for i, (method, distance, vehicles) in enumerate(results):
            print(f"  {i+1}. {method}: {distance:.2f} (using {vehicles} vehicles)")
    
    return {
        'nearest_neighbor': nn_solution,
        'clarke_wright': cw_solution,
        'improved_nn': improved_nn if 'improved_nn' in locals() else None,
        'improved_cw': improved_cw if 'improved_cw' in locals() else None
    }


def demonstrate_hybrid_approach():
    """Demonstrate a hybrid approach combining multiple heuristics."""
    print("\n" + "="*70)
    print("HYBRID APPROACH: BEST CONSTRUCTIVE + 2-OPT + INTER-ROUTE 2-OPT")
    print("="*70)
    
    # Same problem instance
    depot = (0, 0)
    customers = [
        (4, 4), (6, 2), (8, 6), (2, 8), (10, 4), (12, 2),
        (14, 6), (3, 1), (9, 9), (11, 8), (1, 5), (13, 3)
    ]
    demands = [3, 5, 2, 4, 6, 3, 4, 2, 5, 3, 4, 2]
    vehicle_capacity = 15
    num_vehicles = 4
    
    # Try both constructive heuristics
    nn_solver = NearestNeighborVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    nn_solution = nn_solver.solve()
    
    cw_solver = SavingsAlgorithmVRP(depot, customers, demands, vehicle_capacity, num_vehicles)
    cw_solution = cw_solver.solve()
    
    # Choose the better initial solution
    if nn_solution['feasible'] and cw_solution['feasible']:
        if nn_solution['total_distance'] <= cw_solution['total_distance']:
            best_initial = nn_solution
            best_method = "Nearest Neighbor"
        else:
            best_initial = cw_solution
            best_method = "Clarke-Wright"
    elif nn_solution['feasible']:
        best_initial = nn_solution
        best_method = "Nearest Neighbor"
    elif cw_solution['feasible']:
        best_initial = cw_solution
        best_method = "Clarke-Wright"
    else:
        print("No feasible solution found!")
        return
    
    print(f"Best initial solution: {best_method} with distance {best_initial['total_distance']:.2f}")
    
    # Apply improvements
    opt_solver = TwoOptVRP(depot, customers, demands, vehicle_capacity)
    
    # Step 1: Intra-route 2-opt
    print("\nStep 1: Applying intra-route 2-opt...")
    step1_solution = opt_solver.improve_solution(best_initial['routes'], max_iterations=200)
    
    # Step 2: Inter-route 2-opt
    print("\nStep 2: Applying inter-route 2-opt...")
    final_solution = opt_solver.inter_route_2opt(step1_solution['routes'], max_iterations=200)
    
    # Summary
    print(f"\nHYBRID APPROACH RESULTS:")
    print(f"Initial ({best_method}): {best_initial['total_distance']:.2f}")
    print(f"After intra-route 2-opt: {step1_solution['total_distance']:.2f}")
    print(f"After inter-route 2-opt: {final_solution['total_distance']:.2f}")
    print(f"Total improvement: {best_initial['total_distance'] - final_solution['total_distance']:.2f}")
    print(f"Improvement percentage: {((best_initial['total_distance'] - final_solution['total_distance']) / best_initial['total_distance'] * 100):.1f}%")
    
    print(f"\nFinal routes:")
    for i, route in enumerate(final_solution['routes']):
        route_info = opt_solver.get_route_info(route)
        print(f"  Vehicle {i+1}: Depot -> {' -> '.join(map(str, route))} -> Depot")
        print(f"    Distance: {route_info['distance']:.2f}, Load: {route_info['load']}/{vehicle_capacity} ({route_info['capacity_utilization']:.1%})")


if __name__ == "__main__":
    # Run comparison of individual heuristics
    results = compare_vrp_heuristics()
    
    # Demonstrate hybrid approach
    demonstrate_hybrid_approach()
    
    print("\n" + "="*70)
    print("HEURISTICS SUMMARY")
    print("="*70)
    print("1. Nearest Neighbor: Fast, greedy constructive heuristic")
    print("   - Good for quick solutions")
    print("   - May not find optimal routes")
    print()
    print("2. Clarke-Wright Savings: Classical VRP heuristic")
    print("   - Considers global savings")
    print("   - Often produces better initial solutions")
    print()
    print("3. 2-opt Local Search: Improvement heuristic")
    print("   - Refines existing solutions")
    print("   - Can be applied to any initial solution")
    print("   - Both intra-route and inter-route variants")
    print()
    print("4. Hybrid Approach: Combines the best of all methods")
    print("   - Use best constructive heuristic as starting point")
    print("   - Apply multiple improvement phases")
    print("   - Generally produces the best results")