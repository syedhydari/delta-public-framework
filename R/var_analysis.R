#' Value at Risk (VaR) Calculations
#' 
#' This module provides functions for calculating Value at Risk using different methods
#' commonly used in quantitative risk management.
#' 
#' @author Delta QRM Framework
#' @date 2025

library(tidyverse)
library(quantmod)

#' Calculate Historical VaR
#' 
#' @param returns Numeric vector of portfolio returns
#' @param confidence_level Confidence level (default 0.95 for 95% VaR)
#' @param portfolio_value Portfolio value in dollars
#' @return VaR value in dollars
historical_var <- function(returns, confidence_level = 0.95, portfolio_value = 1000000) {
  if (length(returns) < 30) {
    warning("Insufficient data: recommend at least 30 observations for reliable VaR")
  }
  
  alpha <- 1 - confidence_level
  var_percentile <- quantile(returns, alpha, na.rm = TRUE)
  var_dollar <- abs(var_percentile * portfolio_value)
  
  return(list(
    var_percent = var_percentile,
    var_dollar = var_dollar,
    confidence_level = confidence_level
  ))
}

#' Calculate Parametric VaR (Normal Distribution)
#' 
#' @param returns Numeric vector of portfolio returns
#' @param confidence_level Confidence level
#' @param portfolio_value Portfolio value in dollars
#' @return VaR value assuming normal distribution
parametric_var <- function(returns, confidence_level = 0.95, portfolio_value = 1000000) {
  returns_mean <- mean(returns, na.rm = TRUE)
  returns_sd <- sd(returns, na.rm = TRUE)
  
  alpha <- 1 - confidence_level
  z_score <- qnorm(alpha)
  
  var_percent <- returns_mean + z_score * returns_sd
  var_dollar <- abs(var_percent * portfolio_value)
  
  return(list(
    var_percent = var_percent,
    var_dollar = var_dollar,
    confidence_level = confidence_level,
    mean = returns_mean,
    sd = returns_sd
  ))
}

#' Calculate Expected Shortfall (Conditional VaR)
#' 
#' @param returns Numeric vector of portfolio returns
#' @param confidence_level Confidence level
#' @param portfolio_value Portfolio value in dollars
#' @return Expected Shortfall value
expected_shortfall <- function(returns, confidence_level = 0.95, portfolio_value = 1000000) {
  alpha <- 1 - confidence_level
  var_threshold <- quantile(returns, alpha, na.rm = TRUE)
  
  # Calculate average of returns below VaR threshold
  tail_returns <- returns[returns <= var_threshold]
  es_percent <- mean(tail_returns, na.rm = TRUE)
  es_dollar <- abs(es_percent * portfolio_value)
  
  return(list(
    es_percent = es_percent,
    es_dollar = es_dollar,
    confidence_level = confidence_level,
    var_threshold = var_threshold
  ))
}

#' Monte Carlo VaR Simulation
#' 
#' @param returns Historical returns for parameter estimation
#' @param n_simulations Number of Monte Carlo simulations
#' @param confidence_level Confidence level
#' @param portfolio_value Portfolio value
monte_carlo_var <- function(returns, n_simulations = 10000, confidence_level = 0.95, portfolio_value = 1000000) {
  returns_mean <- mean(returns, na.rm = TRUE)
  returns_sd <- sd(returns, na.rm = TRUE)
  
  # Generate random returns assuming normal distribution
  simulated_returns <- rnorm(n_simulations, mean = returns_mean, sd = returns_sd)
  
  alpha <- 1 - confidence_level
  var_percent <- quantile(simulated_returns, alpha)
  var_dollar <- abs(var_percent * portfolio_value)
  
  return(list(
    var_percent = var_percent,
    var_dollar = var_dollar,
    confidence_level = confidence_level,
    simulated_returns = simulated_returns,
    n_simulations = n_simulations
  ))
}

#' Comprehensive VaR Analysis
#' 
#' @param returns Vector of returns
#' @param confidence_levels Vector of confidence levels to analyze
#' @param portfolio_value Portfolio value
var_analysis <- function(returns, confidence_levels = c(0.90, 0.95, 0.99), portfolio_value = 1000000) {
  results <- tibble()
  
  for (conf_level in confidence_levels) {
    hist_var <- historical_var(returns, conf_level, portfolio_value)
    param_var <- parametric_var(returns, conf_level, portfolio_value)
    es <- expected_shortfall(returns, conf_level, portfolio_value)
    
    results <- bind_rows(results, tibble(
      confidence_level = conf_level,
      historical_var = hist_var$var_dollar,
      parametric_var = param_var$var_dollar,
      expected_shortfall = es$es_dollar
    ))
  }
  
  return(results)
}

# Example usage and testing
if (interactive()) {
  cat("Value at Risk Analysis Example\n")
  cat("==============================\n\n")
  
  # Generate sample returns (daily returns for demonstration)
  set.seed(123)
  sample_returns <- rnorm(252, mean = 0.0008, sd = 0.02)  # 252 trading days
  
  # Perform VaR analysis
  var_results <- var_analysis(sample_returns, portfolio_value = 1000000)
  print(var_results)
  
  # Plot return distribution
  hist(sample_returns, breaks = 30, main = "Distribution of Daily Returns", 
       xlab = "Daily Returns", col = "lightblue", border = "white")
  abline(v = quantile(sample_returns, 0.05), col = "red", lwd = 2, lty = 2)
  legend("topright", "95% VaR", col = "red", lwd = 2, lty = 2)
}