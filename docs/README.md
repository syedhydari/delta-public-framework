# Delta Quantitative Risk Management Framework

## Overview

The Delta QRM Framework is an educational R package designed for quantitative risk management coursework at Columbia University. It provides comprehensive tools for risk analysis, portfolio optimization, and financial modeling, optimized for use with Positron IDE.

## Features

### Core Risk Management Tools
- **Value at Risk (VaR)** - Historical, parametric, and Monte Carlo VaR calculations
- **Expected Shortfall** - Conditional VaR and tail risk measures
- **Portfolio Optimization** - Mean-variance optimization and efficient frontier
- **Monte Carlo Simulation** - Portfolio simulation and scenario analysis
- **Risk Factor Modeling** - CAPM, multi-factor models, and PCA analysis
- **Stress Testing** - Scenario-based risk assessment

### Educational Focus
- Comprehensive documentation and examples
- Step-by-step tutorials for each methodology
- Integration with modern R practices (tidyverse)
- Designed for academic learning and research

## Getting Started

### Prerequisites
- R 4.0 or higher
- Positron IDE (recommended) or RStudio
- Basic knowledge of R programming

### Installation

1. Clone or download this repository
2. Open the `delta-qrm.Rproj` file in Positron IDE
3. Install required packages:
   ```r
   source("setup_packages.R")
   ```

### Quick Start

Run the introduction script to familiarize yourself with the framework:
```r
source("examples/intro_to_qrm.R")
```

For a comprehensive demonstration:
```r
source("examples/comprehensive_qrm_analysis.R")
```

## Project Structure

```
delta-public-framework/
├── README.md                          # This file
├── delta-qrm.Rproj                   # R project file
├── .Rprofile                         # R startup configuration
├── setup_packages.R                  # Package installation script
├── R/                                # Core R functions
│   ├── var_analysis.R               # VaR calculations
│   ├── portfolio_optimization.R     # Portfolio optimization
│   ├── monte_carlo.R               # Monte Carlo simulations
│   └── risk_factors.R              # Factor models
├── examples/                         # Example scripts and tutorials
│   ├── intro_to_qrm.R             # Introduction and overview
│   └── comprehensive_qrm_analysis.R # Complete analysis example
├── data/                            # Sample datasets
├── docs/                           # Documentation
└── tests/                          # Unit tests
```

## Core Modules

### 1. Value at Risk Analysis (`R/var_analysis.R`)

Calculate VaR using different methodologies:

```r
source("R/var_analysis.R")

# Historical VaR
returns <- rnorm(252, 0.001, 0.02)
var_95 <- historical_var(returns, 0.95, 1000000)

# Parametric VaR (normal distribution)
param_var <- parametric_var(returns, 0.95, 1000000)

# Expected Shortfall
es_95 <- expected_shortfall(returns, 0.95, 1000000)
```

### 2. Portfolio Optimization (`R/portfolio_optimization.R`)

Modern portfolio theory implementation:

```r
source("R/portfolio_optimization.R")

# Minimum variance portfolio
min_var_port <- min_variance_portfolio(returns_matrix)

# Maximum Sharpe ratio portfolio
max_sharpe_port <- max_sharpe_portfolio(returns_matrix)

# Efficient frontier
frontier <- efficient_frontier(returns_matrix)
plot_efficient_frontier(frontier, returns_matrix)
```

### 3. Monte Carlo Simulation (`R/monte_carlo.R`)

Risk simulation and scenario analysis:

```r
source("R/monte_carlo.R")

# Portfolio simulation
mc_results <- monte_carlo_portfolio(
  initial_value = 1000000,
  expected_returns = c(0.08, 0.06, 0.04)/252,
  cov_matrix = cov_matrix,
  weights = c(0.4, 0.4, 0.2),
  n_simulations = 1000,
  time_horizon = 252
)

# Stress testing
scenarios <- generate_stress_scenarios(returns_matrix, "market_crash", 2)
stress_results <- portfolio_stress_test(returns_matrix, weights, scenarios)
```

### 4. Risk Factor Models (`R/risk_factors.R`)

Factor-based risk analysis:

```r
source("R/risk_factors.R")

# CAPM model
capm_result <- single_factor_model(asset_returns, market_returns)

# Multi-factor model
ff_result <- multi_factor_model(asset_returns, market_returns, smb_returns, hml_returns)

# Principal component analysis
pca_factors <- pca_risk_factors(returns_matrix, n_factors = 3)
```

## Positron IDE Integration

This framework is optimized for Positron IDE with:

- **Project Structure**: Organized .Rproj file for seamless project management
- **Environment Setup**: Automatic package loading and configuration
- **Interactive Analysis**: Built-in plotting and data visualization
- **Integrated Terminal**: Easy access to R console and commands
- **Modern R Practices**: Integration with tidyverse and modern R workflows

### Positron-Specific Features

1. **Auto-detection**: Framework automatically detects Positron IDE environment
2. **Enhanced Plotting**: Optimized plot rendering in Positron viewer
3. **Workspace Management**: Integrated with Positron's workspace features
4. **Package Management**: Streamlined package installation and loading

## Educational Applications

This framework is designed for use in quantitative risk management courses, including:

### Course Topics Covered
- **Risk Measurement**: VaR, Expected Shortfall, risk metrics
- **Portfolio Theory**: Modern portfolio theory, optimization
- **Factor Models**: CAPM, Fama-French, custom factor models
- **Simulation Methods**: Monte Carlo, stress testing, scenario analysis
- **Risk Management**: Portfolio risk, factor risk, tail risk

### Learning Objectives
- Understand fundamental risk management concepts
- Implement risk models in R
- Perform quantitative risk analysis
- Interpret and communicate risk results
- Apply modern computational methods to finance

## Examples and Tutorials

### Basic VaR Analysis
```r
# Load sample data
returns <- rnorm(252, 0.0008, 0.015)

# Calculate different VaR measures
var_analysis(returns, c(0.90, 0.95, 0.99), 1000000)
```

### Portfolio Optimization Example
```r
# Create sample returns matrix
set.seed(123)
returns_matrix <- matrix(rnorm(252*4, 0.0008, 0.02), 252, 4)
colnames(returns_matrix) <- c("Asset1", "Asset2", "Asset3", "Asset4")

# Find optimal portfolios
min_var <- min_variance_portfolio(returns_matrix)
max_sharpe <- max_sharpe_portfolio(returns_matrix)

# Plot efficient frontier
frontier <- efficient_frontier(returns_matrix)
plot_efficient_frontier(frontier, returns_matrix)
```

## Contributing

This is an educational framework. For course-related questions or suggestions:

1. Review existing documentation and examples
2. Check the course materials for additional context
3. Consult with course instructors for academic guidance

## License

This work is licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0). See LICENSE.md for details.

## Disclaimer

This framework is for educational purposes only. It is not intended for commercial use or actual investment decisions. All examples use synthetic data for demonstration purposes.

---

**Columbia University - Quantitative Risk Management**  
*Educational Framework for Risk Analysis in R*