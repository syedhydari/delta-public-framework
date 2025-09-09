#' Comprehensive Quantitative Risk Management Example
#' 
#' This script demonstrates the main functions of the Delta QRM Framework
#' for educational purposes in quantitative risk management.
#' 
#' Author: Delta QRM Framework
#' Course: Quantitative Risk Management - Columbia University

# Load required libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(quantmod)
  library(PerformanceAnalytics)
})

# Source all QRM functions
source(here::here("R", "var_analysis.R"))
source(here::here("R", "portfolio_optimization.R"))
source(here::here("R", "monte_carlo.R"))
source(here::here("R", "risk_factors.R"))

cat("Delta Quantitative Risk Management Framework\n")
cat("============================================\n")
cat("Columbia University - Educational Example\n\n")

# =============================================================================
# 1. DATA PREPARATION
# =============================================================================

cat("1. Loading and Preparing Market Data\n")
cat("====================================\n")

# For demonstration, we'll create synthetic market data
# In practice, you would load real market data
set.seed(42)  # For reproducible results

# Create synthetic daily returns for a portfolio of assets
n_days <- 504  # 2 years of daily data
asset_names <- c("US_Equity", "Intl_Equity", "US_Bonds", "Commodities")
n_assets <- length(asset_names)

# Expected returns (annualized)
expected_returns_annual <- c(0.08, 0.06, 0.03, 0.05)
expected_returns_daily <- expected_returns_annual / 252

# Correlation matrix
correlation_matrix <- matrix(c(
  1.00, 0.70, 0.20, 0.30,
  0.70, 1.00, 0.15, 0.25,
  0.20, 0.15, 1.00, -0.10,
  0.30, 0.25, -0.10, 1.00
), nrow = 4, byrow = TRUE)

# Volatilities (annualized)
volatilities_annual <- c(0.16, 0.18, 0.04, 0.22)
volatilities_daily <- volatilities_annual / sqrt(252)

# Create covariance matrix
cov_matrix <- diag(volatilities_daily) %*% correlation_matrix %*% diag(volatilities_daily)

# Generate correlated returns
library(MASS)
returns_matrix <- mvrnorm(n = n_days, mu = expected_returns_daily, Sigma = cov_matrix)
colnames(returns_matrix) <- asset_names

# Convert to data frame with dates
dates <- seq.Date(from = as.Date("2022-01-01"), by = "day", length.out = n_days)
# Remove weekends (simplified)
weekdays_idx <- which(weekdays(dates) %in% c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday"))
returns_df <- data.frame(
  date = dates[weekdays_idx][1:min(n_days, length(weekdays_idx))],
  returns_matrix[1:min(n_days, length(weekdays_idx)), ]
)

cat("Generated", nrow(returns_df), "days of returns for", n_assets, "assets\n\n")

# =============================================================================
# 2. VALUE AT RISK ANALYSIS
# =============================================================================

cat("2. Value at Risk Analysis\n")
cat("=========================\n")

# Portfolio weights (example: 40% US Equity, 20% Intl Equity, 30% Bonds, 10% Commodities)
portfolio_weights <- c(0.40, 0.20, 0.30, 0.10)
names(portfolio_weights) <- asset_names

# Calculate portfolio returns
portfolio_returns <- as.matrix(returns_df[, -1]) %*% portfolio_weights

# Perform comprehensive VaR analysis
portfolio_value <- 10000000  # $10 million portfolio
var_results <- var_analysis(portfolio_returns, portfolio_value = portfolio_value)

cat("Portfolio VaR Analysis (Portfolio Value: $", format(portfolio_value, big.mark = ","), ")\n")
print(var_results)
cat("\n")

# =============================================================================
# 3. PORTFOLIO OPTIMIZATION
# =============================================================================

cat("3. Portfolio Optimization\n")
cat("=========================\n")

# Calculate optimal portfolios
returns_matrix_clean <- returns_df[, -1]

# Minimum variance portfolio
min_var_port <- min_variance_portfolio(returns_matrix_clean)
cat("Minimum Variance Portfolio Weights:\n")
print(round(min_var_port$weights, 4))
cat("Portfolio Risk (daily):", round(min_var_port$stats$risk, 4), "\n\n")

# Maximum Sharpe ratio portfolio
max_sharpe_port <- max_sharpe_portfolio(returns_matrix_clean)
cat("Maximum Sharpe Ratio Portfolio Weights:\n")
print(round(max_sharpe_port$weights, 4))
cat("Sharpe Ratio:", round(max_sharpe_port$stats$sharpe_ratio, 4), "\n\n")

# Generate efficient frontier
frontier_portfolios <- efficient_frontier(returns_matrix_clean, n_portfolios = 25)
cat("Generated efficient frontier with", length(frontier_portfolios), "portfolios\n\n")

# =============================================================================
# 4. MONTE CARLO SIMULATION
# =============================================================================

cat("4. Monte Carlo Simulation\n")
cat("=========================\n")

# Run Monte Carlo simulation for current portfolio
mc_simulation <- monte_carlo_portfolio(
  initial_value = portfolio_value,
  expected_returns = expected_returns_daily,
  cov_matrix = cov_matrix,
  weights = portfolio_weights,
  n_simulations = 1000,
  time_horizon = 252  # 1 year
)

cat("Monte Carlo Simulation completed:\n")
cat("- Initial Value: $", format(portfolio_value, big.mark = ","), "\n")
cat("- Time Horizon: 1 year (252 days)\n")
cat("- Number of Simulations: 1,000\n\n")

# Calculate key statistics
final_values <- mc_simulation$final_values
prob_loss <- mean(final_values < portfolio_value) * 100
median_final <- median(final_values)
percentile_5 <- quantile(final_values, 0.05)

cat("Results:\n")
cat("- Probability of Loss: ", sprintf("%.1f%%", prob_loss), "\n")
cat("- Median Final Value: $", format(round(median_final), big.mark = ","), "\n")
cat("- 5th Percentile (95% VaR): $", format(round(percentile_5), big.mark = ","), "\n")
cat("- Potential Loss (95% confidence): $", format(round(portfolio_value - percentile_5), big.mark = ","), "\n\n")

# =============================================================================
# 5. STRESS TESTING
# =============================================================================

cat("5. Stress Testing\n")
cat("================\n")

# Generate stress scenarios
market_crash_scenario <- generate_stress_scenarios(returns_matrix_clean, "market_crash", severity = 2)
rate_shock_scenario <- generate_stress_scenarios(returns_matrix_clean, "interest_rate_shock", severity = 2)

# Combine scenarios
all_scenarios <- c(market_crash_scenario, rate_shock_scenario)

# Perform stress tests
stress_results <- portfolio_stress_test(returns_matrix_clean, portfolio_weights, all_scenarios)

# Display results
stress_summary <- scenario_analysis_summary(stress_results)

# =============================================================================
# 6. FACTOR MODEL ANALYSIS
# =============================================================================

cat("\n6. Factor Model Analysis\n")
cat("========================\n")

# For demonstration, assume first asset is market proxy
market_returns <- returns_matrix_clean[, 1]
asset_returns <- returns_matrix_clean[, 2]  # International equity

# Fit CAPM model
capm_model <- single_factor_model(asset_returns, market_returns)

cat("CAPM Model Results (International Equity vs US Equity):\n")
cat("- Alpha (annualized): ", sprintf("%.2f%%", capm_model$alpha * 252 * 100), "\n")
cat("- Beta: ", sprintf("%.3f", capm_model$beta), "\n")
cat("- R-squared: ", sprintf("%.3f", capm_model$r_squared), "\n")
cat("- Tracking Error (annualized): ", sprintf("%.2f%%", capm_model$tracking_error * sqrt(252) * 100), "\n\n")

# =============================================================================
# 7. SUMMARY AND RECOMMENDATIONS
# =============================================================================

cat("7. Risk Management Summary\n")
cat("==========================\n")

cat("Current Portfolio Analysis:\n")
cat("- Portfolio Value: $", format(portfolio_value, big.mark = ","), "\n")
cat("- Daily VaR (95%): $", format(round(var_results$historical_var[2]), big.mark = ","), "\n")
cat("- Daily VaR (99%): $", format(round(var_results$historical_var[3]), big.mark = ","), "\n")
cat("- Expected Shortfall (95%): $", format(round(var_results$expected_shortfall[2]), big.mark = ","), "\n\n")

cat("Risk Factors:\n")
cat("- Equity Risk: ", sprintf("%.1f%%", (portfolio_weights[1] + portfolio_weights[2]) * 100), " allocation\n")
cat("- Interest Rate Risk: ", sprintf("%.1f%%", portfolio_weights[3] * 100), " bond allocation\n")
cat("- Commodity Risk: ", sprintf("%.1f%%", portfolio_weights[4] * 100), " allocation\n\n")

cat("Stress Test Results:\n")
cat("- Market Crash Scenario: Potential loss up to $", 
    format(round(max(abs(stress_summary$VaR_99[stress_summary$Scenario != "Historical Baseline"])) * portfolio_value / 100), big.mark = ","), "\n")

cat("\nRecommendations:\n")
cat("1. Monitor daily VaR limits and adjust positions if exceeded\n")
cat("2. Implement stress testing on a monthly basis\n")
cat("3. Consider diversification benefits of alternative assets\n")
cat("4. Review factor exposures regularly\n")
cat("5. Update risk models with new market data\n\n")

cat("Analysis completed successfully!\n")
cat("========================================\n")

# Optional: Save results for further analysis
if (interactive()) {
  save_results <- readline("Save results to RData file? (y/n): ")
  if (tolower(save_results) == "y") {
    save(var_results, stress_results, mc_simulation, capm_model,
         file = here::here("examples", "qrm_analysis_results.RData"))
    cat("Results saved to examples/qrm_analysis_results.RData\n")
  }
}