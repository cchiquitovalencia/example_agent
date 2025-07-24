# Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet (MDVRPTWH) Solver

[![R](https://img.shields.io/badge/R-%3E%3D%204.0-blue)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-Web%20App-green)](https://shiny.rstudio.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive Shiny web application for solving the Multi-Depot Vehicle Routing Problem with Time Windows and Heterogeneous Fleet (MDVRPTWH). This MVP implementation provides multiple solving algorithms, interactive visualizations, and a complete testing suite.

## 🚀 Features

### Core Functionality
- **Multiple Depots**: Support for 2+ depot locations
- **Time Windows**: Customer service time constraints
- **Heterogeneous Fleet**: Different vehicle types (Small Van, Large Truck)
- **Capacity Constraints**: Vehicle load limitations
- **Interactive Web Interface**: User-friendly Shiny dashboard

### Solving Algorithms
1. **Nearest Neighbor**: Fast greedy heuristic for quick solutions
2. **Greedy Best Insertion**: Better quality solutions with insertion heuristic
3. **Simulated Annealing**: Metaheuristic for high-quality optimization

### Visualizations
- **Route Maps**: Interactive plots showing vehicle routes
- **Vehicle Utilization**: Load capacity analysis
- **Time Windows**: Gantt-style service time visualization
- **Performance Metrics**: Solution cost and timing analysis

### Quality Assurance
- **Comprehensive Unit Tests**: 20+ test cases covering all functions
- **Input Validation**: Problem instance verification
- **Solution Validation**: Constraint checking and feasibility analysis
- **Error Handling**: Graceful handling of edge cases

## 📊 Problem Instance

### Default Configuration
- **Depots**: 2 locations with operating hours
- **Customers**: 7 customers with demands and time windows
- **Vehicles**: 2 vehicles of different types
- **Vehicle Types**: Small Van (capacity: 100) and Large Truck (capacity: 200)

### Customizable Parameters
- Number of depots (1-5)
- Number of customers (1-20)
- Number of vehicles (1-10)
- Number of vehicle types (1-5)
- Grid size for coordinate generation
- Random seed for reproducibility

## 🛠️ Installation

### Prerequisites
- R (version 4.0 or higher)
- RStudio (recommended)

### Required R Packages
```r
# Install required packages
install.packages(c(
  "shiny",
  "shinydashboard", 
  "dplyr",
  "plotly",
  "RColorBrewer",
  "DT",
  "testthat"
))
```

### Quick Start
1. Clone or download this repository
2. Open R/RStudio and set working directory to the project folder
3. Install required packages (see above)
4. Run the application:
```r
shiny::runApp("app.R")
```

## 📖 Usage Guide

### 1. Problem Setup
1. Navigate to the **Problem Setup** tab
2. Adjust parameters (depots, customers, vehicles, vehicle types)
3. Click **Generate Problem Instance**
4. Review the generated data in the tables below

### 2. Solving
1. Go to the **Solution** tab
2. Select a solving method:
   - **Nearest Neighbor**: Fast, basic quality
   - **Greedy**: Medium speed, better quality
   - **Simulated Annealing**: Slow, best quality
3. Set max iterations (for Simulated Annealing)
4. Click **Solve Problem**
5. Review solution summary and route details

### 3. Visualization
1. Visit the **Visualization** tab
2. Explore interactive plots:
   - **Route Map**: See vehicle paths on coordinate plane
   - **Vehicle Utilization**: Analyze load distribution
   - **Time Windows**: Check service timing compliance

### 4. Documentation
- **Problem Description**: Mathematical formulation and background
- **Algorithm Documentation**: Detailed algorithm explanations
- **API Reference**: Function documentation and usage examples

## 🧪 Testing

### Running Unit Tests
```r
# Run all tests
source("tests/run_tests.R")

# Run specific test files
testthat::test_file("tests/test_problem_definition.R")
testthat::test_file("tests/test_solver.R")

# Detailed test output
testthat::test_dir("tests", reporter = "detailed")
```

### Test Coverage
- **Problem Definition**: 15 test cases
- **Solver Functions**: 15 test cases
- **Edge Cases**: Boundary conditions and error handling
- **Algorithm Validation**: Solution feasibility and correctness

## 📁 Project Structure

```
mdvrptwh-solver/
├── app.R                    # Main Shiny application
├── README.md               # This file
├── requirements.txt        # R package dependencies
├── R/                      # Core R functions
│   ├── problem_definition.R  # Problem instance generation
│   ├── solver.R              # Optimization algorithms  
│   └── visualization.R       # Plotting functions
├── docs/                   # Documentation
│   ├── problem_description.md
│   ├── algorithms.md
│   └── api_reference.md
└── tests/                  # Unit tests
    ├── run_tests.R
    ├── test_problem_definition.R
    └── test_solver.R
```

## 🔬 Algorithm Details

### Nearest Neighbor
- **Complexity**: O(n² × v)
- **Use Case**: Quick baseline solutions
- **Characteristics**: Fast but often suboptimal

### Greedy Best Insertion  
- **Complexity**: O(n³ × v)
- **Use Case**: Balanced performance
- **Characteristics**: Better optimization than NN

### Simulated Annealing
- **Complexity**: O(iterations × neighborhood_size)
- **Use Case**: High-quality solutions
- **Characteristics**: Can escape local optima

## 📈 Performance Metrics

### Typical Performance (7 customers, 2 depots, 2 vehicles)
- **Nearest Neighbor**: ~0.01 seconds
- **Greedy Insertion**: ~0.05 seconds  
- **Simulated Annealing**: ~0.5 seconds (1000 iterations)

### Solution Quality Ranking
1. Simulated Annealing (best cost)
2. Greedy Best Insertion
3. Nearest Neighbor (fastest)

## 🤝 Contributing

### Development Guidelines
1. Follow R coding standards
2. Add unit tests for new functions
3. Update documentation for API changes
4. Test with different problem sizes

### Adding New Algorithms
1. Implement in `R/solver.R`
2. Add to `solve_mdvrptwh()` switch statement
3. Create corresponding unit tests
4. Update documentation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Vehicle Routing Problem research community
- R Shiny development team
- Open source optimization libraries

## 📞 Support

For questions or issues:
1. Check the documentation in the `docs/` folder
2. Review the unit tests for usage examples
3. Examine the API reference for function details

## 🔮 Future Enhancements

### Planned Features
- [ ] Additional neighborhood operators for SA
- [ ] Multi-objective optimization
- [ ] Import/export of problem instances
- [ ] Real-world map integration
- [ ] Performance benchmarking suite
- [ ] Advanced constraint handling

### Algorithm Improvements
- [ ] Genetic Algorithm implementation
- [ ] Ant Colony Optimization
- [ ] Variable Neighborhood Search
- [ ] Parallel processing support

---

**Built with ❤️ using R and Shiny**
