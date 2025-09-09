# Getting Started with Delta QRM Framework

## Quick Start Guide for Positron IDE

### 1. Initial Setup

1. **Open Project**: Open `delta-qrm.Rproj` in Positron IDE
2. **Quick Test**: Run `source("examples/standalone_demo.R")` to verify basic functionality
3. **Install Packages**: Run `source("setup_packages.R")` to install required R packages

### 2. Framework Overview

The Delta QRM Framework provides comprehensive tools for quantitative risk management education, including:

- **Value at Risk (VaR)** - Multiple calculation methods (historical, parametric, Monte Carlo)
- **Expected Shortfall** - Tail risk measures beyond VaR
- **Portfolio Optimization** - Mean-variance optimization and efficient frontier
- **Monte Carlo Simulation** - Risk scenario modeling and stress testing
- **Factor Models** - CAPM, multi-factor models, and PCA analysis

### 3. Learning Path

#### Beginner: Start Here
```r
# 1. Quick demo (no packages required)
source("examples/standalone_demo.R")

# 2. Introduction to framework
source("examples/intro_to_qrm.R")
```

#### Intermediate: Core Modules
```r
# 3. Value at Risk analysis
source("R/var_analysis.R")
returns <- rnorm(252, 0.001, 0.02)
var_result <- historical_var(returns, 0.95, 1000000)

# 4. Portfolio optimization
source("R/portfolio_optimization.R")
min_var_port <- min_variance_portfolio(returns_matrix)
```

#### Advanced: Comprehensive Analysis
```r
# 5. Full quantitative risk management workflow
source("examples/comprehensive_qrm_analysis.R")
```

### 4. File Structure Navigation

```
delta-public-framework/
├── R/                          # Core QRM functions
│   ├── var_analysis.R         # VaR calculations
│   ├── portfolio_optimization.R # Portfolio theory
│   ├── monte_carlo.R          # Simulations
│   └── risk_factors.R         # Factor models
├── examples/                   # Learning materials
│   ├── standalone_demo.R      # Quick demo
│   ├── intro_to_qrm.R        # Introduction
│   └── comprehensive_qrm_analysis.R # Full analysis
├── data/                      # Sample datasets
└── docs/                      # Documentation
```

### 5. Positron IDE Features

- **Project Management**: Automatic environment setup via `.Rprofile`
- **Integrated Plotting**: Visualizations appear in the Plots pane
- **Package Management**: Streamlined installation with `setup_packages.R`
- **Interactive Console**: Enhanced R console for exploration
- **Environment Tracking**: Monitor variables and functions

### 6. Educational Applications

#### Course Topics Covered:
- Risk measurement and VaR methodologies
- Modern portfolio theory and optimization
- Factor models and risk decomposition
- Monte Carlo methods in finance
- Stress testing and scenario analysis

#### Assignments and Projects:
- Calculate portfolio VaR using different methods
- Optimize portfolios under various constraints
- Implement factor models for risk attribution
- Design stress tests for portfolio evaluation
- Build comprehensive risk management systems

### 7. Sample Analyses

#### Basic VaR Calculation:
```r
# Load sample data
load("data/portfolio_returns_sample.RData")
returns <- portfolio_returns_sample$US_Large_Cap

# Calculate 95% VaR
var_result <- historical_var(returns, 0.95, 1000000)
print(paste("95% VaR:", scales::dollar(var_result$var_dollar)))
```

#### Portfolio Optimization:
```r
# Load portfolio data
returns_matrix <- as.matrix(portfolio_returns_sample[, -1])

# Find optimal portfolios
min_var <- min_variance_portfolio(returns_matrix)
max_sharpe <- max_sharpe_portfolio(returns_matrix)

# Compare allocations
print("Minimum Variance Weights:")
print(round(min_var$weights, 3))
```

### 8. Troubleshooting

#### Common Issues:
1. **Package Installation**: If packages fail to install, check internet connection and run `source("setup_packages.R")` again
2. **Missing Data**: Sample datasets are created automatically when running data scripts
3. **Function Not Found**: Ensure you've sourced the correct R module first

#### Getting Help:
- Check the `docs/` directory for detailed documentation
- Review example scripts in `examples/` directory
- Use R help: `?function_name` for built-in help
- Run basic tests: `source("tests/basic_tests.R")`

### 9. Best Practices

- **Project Organization**: Keep all work within the project directory
- **Version Control**: Use git to track changes to your analyses
- **Documentation**: Comment your code for future reference
- **Data Management**: Store custom datasets in the `data/` directory
- **Results Sharing**: Save important results and plots for presentations

### 10. Next Steps

Once comfortable with the framework:
1. Implement custom risk models for specific assets
2. Extend portfolio optimization with additional constraints
3. Build interactive dashboards for risk reporting
4. Integrate real market data from financial APIs
5. Develop backtesting frameworks for strategy evaluation

---

**Ready to start your quantitative risk management journey!**

*For Columbia University students: This framework supports all major topics in quantitative risk management coursework.*