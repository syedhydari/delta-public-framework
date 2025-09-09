#' Monte Carlo Simulation for Risk Management
#' 
#' Functions for Monte Carlo simulation in quantitative risk management,
#' including portfolio simulation, scenario generation, and stress testing.
#' 
#' @author Delta QRM Framework

library(tidyverse)
library(MASS)

#' Monte Carlo Portfolio Simulation
#' 
#' @param initial_value Initial portfolio value
#' @param expected_returns Vector of expected returns for each asset
#' @param cov_matrix Covariance matrix of asset returns
#' @param weights Portfolio weights
#' @param n_simulations Number of simulation paths
#' @param time_horizon Time horizon in days
#' @param rebalance_freq Rebalancing frequency (days)
monte_carlo_portfolio <- function(initial_value = 1000000,
                                 expected_returns,
                                 cov_matrix,
                                 weights,
                                 n_simulations = 1000,
                                 time_horizon = 252,
                                 rebalance_freq = 21) {
  
  n_assets <- length(weights)
  weights <- weights / sum(weights)  # Normalize weights
  
  # Portfolio expected return and volatility
  portfolio_return <- sum(weights * expected_returns)
  portfolio_vol <- sqrt(t(weights) %*% cov_matrix %*% weights)
  
  # Pre-allocate results matrix
  portfolio_values <- matrix(NA, nrow = n_simulations, ncol = time_horizon + 1)
  portfolio_values[, 1] <- initial_value
  
  # Generate correlated random returns
  set.seed(123)  # For reproducibility
  
  for (sim in 1:n_simulations) {
    current_value <- initial_value
    
    for (day in 1:time_horizon) {
      # Generate random return
      random_return <- rnorm(1, mean = portfolio_return, sd = portfolio_vol)
      
      # Update portfolio value
      current_value <- current_value * (1 + random_return)
      portfolio_values[sim, day + 1] <- current_value
    }
  }
  
  return(list(
    portfolio_values = portfolio_values,
    initial_value = initial_value,
    final_values = portfolio_values[, time_horizon + 1],
    time_horizon = time_horizon,
    n_simulations = n_simulations,
    portfolio_return = portfolio_return,
    portfolio_vol = portfolio_vol
  ))
}

#' Stress Testing Scenarios
#' 
#' @param returns Historical returns matrix
#' @param scenario_type Type of stress scenario
#' @param severity Severity of the stress (1 = mild, 2 = moderate, 3 = severe)
generate_stress_scenarios <- function(returns, scenario_type = "market_crash", severity = 2) {
  
  scenarios <- list()
  
  if (scenario_type == "market_crash") {
    # Market crash scenario - all assets decline
    base_decline <- c(0.10, 0.15, 0.25)[severity]  # 10%, 15%, or 25%
    
    scenarios$market_crash <- list(
      name = paste("Market Crash - Severity", severity),
      returns = apply(returns, 2, function(x) x - base_decline),
      description = paste("All assets decline by", base_decline * 100, "%")
    )
    
  } else if (scenario_type == "interest_rate_shock") {
    # Interest rate shock - affects bonds more than stocks
    rate_increase <- c(0.02, 0.03, 0.05)[severity]  # 2%, 3%, or 5% rate increase
    
    # Assume first half are bonds, second half are stocks
    n_assets <- ncol(returns)
    bond_impact <- -rate_increase * 5  # Duration effect approximation
    stock_impact <- -rate_increase * 0.5  # Indirect effect
    
    stressed_returns <- returns
    stressed_returns[, 1:(n_assets/2)] <- stressed_returns[, 1:(n_assets/2)] + bond_impact
    stressed_returns[, ((n_assets/2)+1):n_assets] <- stressed_returns[, ((n_assets/2)+1):n_assets] + stock_impact
    
    scenarios$interest_rate_shock <- list(
      name = paste("Interest Rate Shock - Severity", severity),
      returns = stressed_returns,
      description = paste("Interest rates increase by", rate_increase * 100, "bps")
    )
    
  } else if (scenario_type == "correlation_breakdown") {
    # Correlation breakdown - diversification fails
    
    # Increase correlations dramatically
    corr_matrix <- cor(returns, use = "complete.obs")
    stressed_corr <- corr_matrix * 0.3 + 0.7 * matrix(0.8, nrow = ncol(returns), ncol = ncol(returns))
    diag(stressed_corr) <- 1
    
    # Generate new returns with high correlation
    sds <- apply(returns, 2, sd, na.rm = TRUE)
    means <- colMeans(returns, na.rm = TRUE)
    
    stressed_returns <- mvrnorm(n = nrow(returns), mu = means, Sigma = diag(sds) %*% stressed_corr %*% diag(sds))
    
    scenarios$correlation_breakdown <- list(
      name = paste("Correlation Breakdown - Severity", severity),
      returns = stressed_returns,
      description = "Asset correlations increase to 0.8 during crisis"
    )
  }
  
  return(scenarios)
}

#' Portfolio Stress Test
#' 
#' @param returns Historical returns matrix
#' @param weights Portfolio weights
#' @param scenarios List of stress scenarios
#' @param confidence_levels VaR confidence levels to calculate
portfolio_stress_test <- function(returns, weights, scenarios, confidence_levels = c(0.95, 0.99)) {
  
  results <- list()
  
  # Baseline (historical) performance
  baseline_returns <- returns %*% weights
  baseline_var <- sapply(confidence_levels, function(cl) {
    quantile(baseline_returns, 1 - cl) * -100  # Convert to positive percentage
  })
  
  results$baseline <- list(
    name = "Historical Baseline",
    portfolio_returns = baseline_returns,
    var = baseline_var,
    mean_return = mean(baseline_returns) * 100,
    volatility = sd(baseline_returns) * 100
  )
  
  # Stress scenarios
  for (scenario_name in names(scenarios)) {
    scenario <- scenarios[[scenario_name]]
    stressed_returns <- scenario$returns %*% weights
    
    stressed_var <- sapply(confidence_levels, function(cl) {
      quantile(stressed_returns, 1 - cl, na.rm = TRUE) * -100
    })
    
    results[[scenario_name]] <- list(
      name = scenario$name,
      description = scenario$description,
      portfolio_returns = stressed_returns,
      var = stressed_var,
      mean_return = mean(stressed_returns, na.rm = TRUE) * 100,
      volatility = sd(stressed_returns, na.rm = TRUE) * 100
    )
  }
  
  return(results)
}

#' Plot Monte Carlo Simulation Results
#' 
#' @param mc_results Output from monte_carlo_portfolio()
#' @param percentiles Percentiles to highlight
plot_monte_carlo <- function(mc_results, percentiles = c(0.05, 0.25, 0.50, 0.75, 0.95)) {
  
  portfolio_values <- mc_results$portfolio_values
  time_steps <- 0:mc_results$time_horizon
  
  # Calculate percentiles for each time step
  percentile_paths <- apply(portfolio_values, 2, quantile, probs = percentiles, na.rm = TRUE)
  
  # Plot setup
  plot(time_steps, percentile_paths[3, ], type = "l", col = "blue", lwd = 2,
       ylim = range(percentile_paths, na.rm = TRUE),
       xlab = "Days", ylab = "Portfolio Value ($)",
       main = paste("Monte Carlo Portfolio Simulation (", mc_results$n_simulations, "paths)"))
  
  # Add percentile bands
  colors <- c("red", "orange", "blue", "orange", "red")
  line_types <- c(2, 2, 1, 2, 2)
  line_widths <- c(1, 1, 2, 1, 1)
  
  for (i in 1:length(percentiles)) {
    lines(time_steps, percentile_paths[i, ], col = colors[i], lty = line_types[i], lwd = line_widths[i])
  }
  
  # Add legend
  legend("topleft", 
         legend = paste0(percentiles * 100, "th percentile"),
         col = colors, lty = line_types, lwd = line_widths,
         cex = 0.8)
  
  # Add grid
  grid()
  
  # Summary statistics
  final_values <- mc_results$final_values
  cat("\nMonte Carlo Simulation Summary:\n")
  cat("===============================\n")
  cat("Initial Value: $", format(mc_results$initial_value, big.mark = ","), "\n")
  cat("Time Horizon:", mc_results$time_horizon, "days\n")
  cat("Number of Simulations:", mc_results$n_simulations, "\n\n")
  
  cat("Final Portfolio Value Percentiles:\n")
  final_percentiles <- quantile(final_values, percentiles, na.rm = TRUE)
  for (i in 1:length(percentiles)) {
    cat(sprintf("%4.0f%%: $%s\n", percentiles[i] * 100, format(round(final_percentiles[i]), big.mark = ",")))
  }
  
  cat("\nProbability of Loss: ", sprintf("%.2f%%", mean(final_values < mc_results$initial_value) * 100), "\n")
}

#' Scenario Analysis Summary
#' 
#' @param stress_results Output from portfolio_stress_test()
scenario_analysis_summary <- function(stress_results) {
  
  confidence_levels <- c(95, 99)
  
  cat("Stress Testing Results\n")
  cat("======================\n\n")
  
  # Create summary table
  summary_table <- data.frame(
    Scenario = character(),
    Mean_Return = numeric(),
    Volatility = numeric(),
    VaR_95 = numeric(),
    VaR_99 = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (scenario_name in names(stress_results)) {
    result <- stress_results[[scenario_name]]
    
    summary_table <- rbind(summary_table, data.frame(
      Scenario = result$name,
      Mean_Return = round(result$mean_return, 2),
      Volatility = round(result$volatility, 2),
      VaR_95 = round(result$var[1], 2),
      VaR_99 = round(result$var[2], 2),
      stringsAsFactors = FALSE
    ))
  }
  
  print(summary_table)
  
  return(summary_table)
}

# Example usage
if (interactive()) {
  cat("Monte Carlo Simulation Example\n")
  cat("==============================\n\n")
  
  # Sample portfolio parameters
  set.seed(123)
  n_assets <- 4
  expected_returns <- c(0.08, 0.06, 0.10, 0.04) / 252  # Daily returns
  
  # Create sample covariance matrix
  correlations <- matrix(c(1.0, 0.3, 0.2, 0.1,
                          0.3, 1.0, 0.1, 0.4,
                          0.2, 0.1, 1.0, 0.2,
                          0.1, 0.4, 0.2, 1.0), nrow = 4)
  volatilities <- c(0.15, 0.12, 0.20, 0.08) / sqrt(252)  # Daily volatilities
  cov_matrix <- diag(volatilities) %*% correlations %*% diag(volatilities)
  
  weights <- c(0.3, 0.3, 0.2, 0.2)
  
  # Run Monte Carlo simulation
  mc_results <- monte_carlo_portfolio(
    initial_value = 1000000,
    expected_returns = expected_returns,
    cov_matrix = cov_matrix,
    weights = weights,
    n_simulations = 1000,
    time_horizon = 252
  )
  
  # Plot results
  plot_monte_carlo(mc_results)
}