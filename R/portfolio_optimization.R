#' Portfolio Optimization Functions
#' 
#' Mean-variance optimization and efficient frontier construction
#' for risk management applications
#' 
#' @author Delta QRM Framework

library(tidyverse)
library(MASS)
library(quadprog)

#' Calculate Portfolio Statistics
#' 
#' @param weights Portfolio weights (must sum to 1)
#' @param returns Matrix of asset returns (assets in columns)
#' @return List with portfolio return, risk, and Sharpe ratio
portfolio_stats <- function(weights, returns, risk_free_rate = 0.02/252) {
  # Ensure weights sum to 1
  weights <- weights / sum(weights)
  
  # Calculate expected returns and covariance matrix
  expected_returns <- colMeans(returns, na.rm = TRUE)
  cov_matrix <- cov(returns, use = "complete.obs")
  
  # Portfolio return and risk
  portfolio_return <- sum(weights * expected_returns)
  portfolio_variance <- t(weights) %*% cov_matrix %*% weights
  portfolio_risk <- sqrt(portfolio_variance)
  
  # Sharpe ratio
  sharpe_ratio <- (portfolio_return - risk_free_rate) / portfolio_risk
  
  return(list(
    weights = weights,
    return = portfolio_return,
    risk = as.numeric(portfolio_risk),
    variance = as.numeric(portfolio_variance),
    sharpe_ratio = as.numeric(sharpe_ratio)
  ))
}

#' Minimum Variance Portfolio
#' 
#' @param returns Matrix of asset returns
#' @return Optimal weights for minimum variance portfolio
min_variance_portfolio <- function(returns) {
  n_assets <- ncol(returns)
  cov_matrix <- cov(returns, use = "complete.obs")
  
  # Quadratic programming setup
  # min(1/2 * w^T * Sigma * w) subject to sum(w) = 1
  Dmat <- 2 * cov_matrix
  dvec <- rep(0, n_assets)
  Amat <- matrix(1, nrow = n_assets, ncol = 1)
  bvec <- 1
  meq <- 1
  
  result <- solve.QP(Dmat = Dmat, dvec = dvec, Amat = Amat, bvec = bvec, meq = meq)
  
  weights <- result$solution
  names(weights) <- colnames(returns)
  
  return(list(
    weights = weights,
    stats = portfolio_stats(weights, returns)
  ))
}

#' Maximum Sharpe Ratio Portfolio
#' 
#' @param returns Matrix of asset returns
#' @param risk_free_rate Risk-free rate
#' @return Optimal weights for maximum Sharpe ratio portfolio
max_sharpe_portfolio <- function(returns, risk_free_rate = 0.02/252) {
  n_assets <- ncol(returns)
  expected_returns <- colMeans(returns, na.rm = TRUE)
  cov_matrix <- cov(returns, use = "complete.obs")
  
  # Excess returns
  excess_returns <- expected_returns - risk_free_rate
  
  # Solve for optimal weights
  inv_cov <- solve(cov_matrix)
  weights_unnorm <- inv_cov %*% excess_returns
  weights <- weights_unnorm / sum(weights_unnorm)
  
  names(weights) <- colnames(returns)
  
  return(list(
    weights = as.numeric(weights),
    stats = portfolio_stats(weights, returns, risk_free_rate)
  ))
}

#' Generate Efficient Frontier
#' 
#' @param returns Matrix of asset returns
#' @param n_portfolios Number of portfolios to generate
#' @param risk_free_rate Risk-free rate
efficient_frontier <- function(returns, n_portfolios = 50, risk_free_rate = 0.02/252) {
  n_assets <- ncol(returns)
  expected_returns <- colMeans(returns, na.rm = TRUE)
  cov_matrix <- cov(returns, use = "complete.obs")
  
  # Range of target returns
  min_ret <- min(expected_returns)
  max_ret <- max(expected_returns)
  target_returns <- seq(min_ret, max_ret, length.out = n_portfolios)
  
  efficient_portfolios <- list()
  
  for (i in seq_along(target_returns)) {
    target_ret <- target_returns[i]
    
    # Quadratic programming for mean-variance optimization
    # min(1/2 * w^T * Sigma * w) 
    # subject to: sum(w) = 1 and w^T * mu = target_ret
    
    Dmat <- 2 * cov_matrix
    dvec <- rep(0, n_assets)
    Amat <- cbind(rep(1, n_assets), expected_returns)
    bvec <- c(1, target_ret)
    meq <- 2
    
    tryCatch({
      result <- solve.QP(Dmat = Dmat, dvec = dvec, Amat = Amat, bvec = bvec, meq = meq)
      weights <- result$solution
      stats <- portfolio_stats(weights, returns, risk_free_rate)
      
      efficient_portfolios[[i]] <- list(
        target_return = target_ret,
        weights = weights,
        realized_return = stats$return,
        risk = stats$risk,
        sharpe_ratio = stats$sharpe_ratio
      )
    }, error = function(e) {
      # Skip if optimization fails
      efficient_portfolios[[i]] <- NULL
    })
  }
  
  # Remove NULL entries
  efficient_portfolios <- efficient_portfolios[!sapply(efficient_portfolios, is.null)]
  
  return(efficient_portfolios)
}

#' Plot Efficient Frontier
#' 
#' @param efficient_portfolios Output from efficient_frontier()
#' @param returns Original returns matrix
plot_efficient_frontier <- function(efficient_portfolios, returns, risk_free_rate = 0.02/252) {
  # Extract risk and return data
  risks <- sapply(efficient_portfolios, function(p) p$risk)
  returns_eff <- sapply(efficient_portfolios, function(p) p$realized_return)
  sharpe_ratios <- sapply(efficient_portfolios, function(p) p$sharpe_ratio)
  
  # Create data frame for plotting
  frontier_data <- data.frame(
    Risk = risks,
    Return = returns_eff,
    Sharpe = sharpe_ratios
  )
  
  # Find maximum Sharpe ratio portfolio
  max_sharpe_idx <- which.max(sharpe_ratios)
  
  # Plot
  plot(risks, returns_eff, type = "l", col = "blue", lwd = 2,
       xlab = "Risk (Standard Deviation)", ylab = "Expected Return",
       main = "Efficient Frontier", xlim = c(0, max(risks) * 1.1))
  
  # Add individual assets
  asset_returns <- colMeans(returns, na.rm = TRUE)
  asset_risks <- apply(returns, 2, sd, na.rm = TRUE)
  points(asset_risks, asset_returns, col = "red", pch = 16, cex = 1.2)
  
  # Highlight maximum Sharpe ratio portfolio
  points(risks[max_sharpe_idx], returns_eff[max_sharpe_idx], 
         col = "green", pch = 16, cex = 1.5)
  
  # Add legend
  legend("topleft", 
         c("Efficient Frontier", "Individual Assets", "Max Sharpe Portfolio"),
         col = c("blue", "red", "green"), 
         lty = c(1, NA, NA), pch = c(NA, 16, 16),
         lwd = c(2, NA, NA))
  
  return(frontier_data)
}

#' Risk Budgeting Portfolio
#' 
#' @param returns Matrix of asset returns  
#' @param risk_budgets Target risk contribution for each asset
risk_budgeting_portfolio <- function(returns, risk_budgets = NULL) {
  n_assets <- ncol(returns)
  
  if (is.null(risk_budgets)) {
    risk_budgets <- rep(1/n_assets, n_assets)  # Equal risk contribution
  }
  
  cov_matrix <- cov(returns, use = "complete.obs")
  
  # Initial equal weights
  weights <- rep(1/n_assets, n_assets)
  
  # Iterative algorithm for risk budgeting
  for (iter in 1:100) {
    portfolio_vol <- sqrt(t(weights) %*% cov_matrix %*% weights)
    marginal_contrib <- (cov_matrix %*% weights) / as.numeric(portfolio_vol)
    contrib <- weights * marginal_contrib
    contrib_pct <- contrib / sum(contrib)
    
    # Update weights based on risk budget deviation
    weights <- weights * (risk_budgets / contrib_pct)
    weights <- weights / sum(weights)  # Normalize
    
    # Check convergence
    if (max(abs(contrib_pct - risk_budgets)) < 1e-6) break
  }
  
  names(weights) <- colnames(returns)
  
  return(list(
    weights = weights,
    risk_contributions = contrib_pct,
    stats = portfolio_stats(weights, returns)
  ))
}

# Example usage
if (interactive()) {
  cat("Portfolio Optimization Example\n")
  cat("==============================\n\n")
  
  # Generate sample asset returns
  set.seed(123)
  n_days <- 252
  n_assets <- 4
  
  returns_matrix <- matrix(rnorm(n_days * n_assets, mean = 0.0008, sd = 0.02), 
                          nrow = n_days, ncol = n_assets)
  colnames(returns_matrix) <- paste0("Asset_", 1:n_assets)
  
  # Calculate different optimal portfolios
  min_var <- min_variance_portfolio(returns_matrix)
  max_sharpe <- max_sharpe_portfolio(returns_matrix)
  
  cat("Minimum Variance Portfolio:\n")
  print(round(min_var$weights, 4))
  cat("Risk:", round(min_var$stats$risk, 4), "\n\n")
  
  cat("Maximum Sharpe Portfolio:\n")
  print(round(max_sharpe$weights, 4))
  cat("Sharpe Ratio:", round(max_sharpe$stats$sharpe_ratio, 4), "\n\n")
  
  # Generate and plot efficient frontier
  frontier <- efficient_frontier(returns_matrix)
  frontier_plot <- plot_efficient_frontier(frontier, returns_matrix)
}