#' Risk Factor Modeling and Analysis
#' 
#' Functions for factor model estimation, risk decomposition,
#' and factor-based risk management
#' 
#' @author Delta QRM Framework

library(tidyverse)
library(broom)

#' Single Factor Model (CAPM)
#' 
#' @param asset_returns Vector of asset returns
#' @param market_returns Vector of market returns
#' @param risk_free_rate Risk-free rate (default annualized 2%)
single_factor_model <- function(asset_returns, market_returns, risk_free_rate = 0.02/252) {
  
  # Calculate excess returns
  excess_asset <- asset_returns - risk_free_rate
  excess_market <- market_returns - risk_free_rate
  
  # Fit regression model
  model <- lm(excess_asset ~ excess_market)
  model_summary <- summary(model)
  
  # Extract parameters
  alpha <- coef(model)[1]
  beta <- coef(model)[2]
  residual_vol <- sigma(model)
  r_squared <- model_summary$r.squared
  
  # Calculate tracking error and information ratio
  tracking_error <- sd(residuals(model), na.rm = TRUE)
  information_ratio <- alpha / tracking_error
  
  return(list(
    model = model,
    alpha = alpha,
    beta = beta,
    r_squared = r_squared,
    residual_volatility = residual_vol,
    tracking_error = tracking_error,
    information_ratio = information_ratio,
    fitted_values = fitted(model),
    residuals = residuals(model)
  ))
}

#' Multi-Factor Model (Fama-French)
#' 
#' @param asset_returns Vector of asset returns
#' @param market_returns Market factor returns
#' @param smb_returns Small-minus-big factor returns
#' @param hml_returns High-minus-low factor returns
#' @param risk_free_rate Risk-free rate
multi_factor_model <- function(asset_returns, market_returns, smb_returns, hml_returns, 
                              risk_free_rate = 0.02/252) {
  
  # Calculate excess returns
  excess_asset <- asset_returns - risk_free_rate
  excess_market <- market_returns - risk_free_rate
  
  # Fit three-factor model
  model <- lm(excess_asset ~ excess_market + smb_returns + hml_returns)
  model_summary <- summary(model)
  
  # Extract factor loadings
  alpha <- coef(model)[1]
  beta_market <- coef(model)[2]
  beta_smb <- coef(model)[3]
  beta_hml <- coef(model)[4]
  
  # Model statistics
  r_squared <- model_summary$r.squared
  residual_vol <- sigma(model)
  
  return(list(
    model = model,
    alpha = alpha,
    beta_market = beta_market,
    beta_smb = beta_smb,
    beta_hml = beta_hml,
    r_squared = r_squared,
    residual_volatility = residual_vol,
    fitted_values = fitted(model),
    residuals = residuals(model)
  ))
}

#' Principal Component Analysis for Risk Factors
#' 
#' @param returns_matrix Matrix of asset returns
#' @param n_factors Number of principal components to extract
pca_risk_factors <- function(returns_matrix, n_factors = 3) {
  
  # Remove any missing values
  clean_returns <- returns_matrix[complete.cases(returns_matrix), ]
  
  # Perform PCA
  pca_result <- prcomp(clean_returns, center = TRUE, scale. = TRUE)
  
  # Extract factor loadings and scores
  factor_loadings <- pca_result$rotation[, 1:n_factors]
  factor_scores <- pca_result$x[, 1:n_factors]
  
  # Calculate variance explained
  variance_explained <- summary(pca_result)$importance[2, 1:n_factors]
  cumulative_variance <- summary(pca_result)$importance[3, 1:n_factors]
  
  # Factor interpretation (based on loadings)
  factor_names <- paste0("PC", 1:n_factors)
  
  return(list(
    pca_result = pca_result,
    factor_loadings = factor_loadings,
    factor_scores = factor_scores,
    variance_explained = variance_explained,
    cumulative_variance = cumulative_variance,
    factor_names = factor_names,
    n_factors = n_factors
  ))
}

#' Risk Attribution Analysis
#' 
#' @param portfolio_returns Vector of portfolio returns
#' @param factor_returns Matrix of factor returns
#' @param portfolio_weights Portfolio weights
risk_attribution <- function(portfolio_returns, factor_returns, portfolio_weights) {
  
  # Fit factor model for portfolio
  factor_model <- lm(portfolio_returns ~ ., data = as.data.frame(factor_returns))
  
  # Factor exposures (betas)
  factor_betas <- coef(factor_model)[-1]  # Exclude intercept
  
  # Factor variances
  factor_vars <- apply(factor_returns, 2, var, na.rm = TRUE)
  
  # Factor contributions to portfolio variance
  factor_contributions <- factor_betas^2 * factor_vars
  
  # Specific risk (residual variance)
  specific_risk <- var(residuals(factor_model), na.rm = TRUE)
  
  # Total portfolio variance
  total_variance <- sum(factor_contributions) + specific_risk
  
  # Risk contributions as percentages
  risk_percentages <- c(factor_contributions, specific_risk) / total_variance * 100
  names(risk_percentages) <- c(names(factor_betas), "Specific Risk")
  
  return(list(
    factor_model = factor_model,
    factor_betas = factor_betas,
    factor_contributions = factor_contributions,
    specific_risk = specific_risk,
    total_variance = total_variance,
    risk_percentages = risk_percentages
  ))
}

#' Style Analysis (Returns-Based)
#' 
#' @param fund_returns Vector of fund returns
#' @param benchmark_returns Matrix of benchmark returns
#' @param window_length Rolling window length for analysis
style_analysis <- function(fund_returns, benchmark_returns, window_length = 36) {
  
  n_obs <- length(fund_returns)
  n_benchmarks <- ncol(benchmark_returns)
  
  # Rolling style analysis
  rolling_weights <- matrix(NA, nrow = n_obs - window_length + 1, ncol = n_benchmarks)
  rolling_rsquared <- numeric(n_obs - window_length + 1)
  
  for (i in window_length:n_obs) {
    start_idx <- i - window_length + 1
    end_idx <- i
    
    # Extract window data
    y <- fund_returns[start_idx:end_idx]
    X <- benchmark_returns[start_idx:end_idx, ]
    
    # Constrained regression (weights sum to 1, no short selling)
    # For simplicity, using unconstrained regression here
    # In practice, would use quadratic programming
    model <- lm(y ~ . - 1, data = as.data.frame(X))  # No intercept
    
    weights <- coef(model)
    weights[is.na(weights)] <- 0
    weights <- pmax(weights, 0)  # No short selling
    weights <- weights / sum(weights)  # Normalize
    
    rolling_weights[i - window_length + 1, ] <- weights
    rolling_rsquared[i - window_length + 1] <- summary(model)$r.squared
  }
  
  colnames(rolling_weights) <- colnames(benchmark_returns)
  
  # Average style weights
  avg_weights <- colMeans(rolling_weights, na.rm = TRUE)
  
  return(list(
    rolling_weights = rolling_weights,
    rolling_rsquared = rolling_rsquared,
    average_weights = avg_weights,
    window_length = window_length
  ))
}

#' Factor Model Diagnostics
#' 
#' @param factor_model_result Output from single_factor_model or multi_factor_model
factor_diagnostics <- function(factor_model_result) {
  
  model <- factor_model_result$model
  residuals <- factor_model_result$residuals
  
  # Residual analysis
  residual_stats <- list(
    mean = mean(residuals, na.rm = TRUE),
    sd = sd(residuals, na.rm = TRUE),
    skewness = moments::skewness(residuals, na.rm = TRUE),
    kurtosis = moments::kurtosis(residuals, na.rm = TRUE),
    jarque_bera = tseries::jarque.bera.test(residuals)$p.value
  )
  
  # Autocorrelation test
  ljung_box <- Box.test(residuals, lag = 10, type = "Ljung-Box")
  
  # Heteroscedasticity test (Breusch-Pagan)
  bp_test <- lmtest::bptest(model)
  
  diagnostics <- list(
    residual_stats = residual_stats,
    autocorrelation_test = ljung_box,
    heteroscedasticity_test = bp_test,
    model_summary = summary(model)
  )
  
  return(diagnostics)
}

#' Plot Factor Model Results
#' 
#' @param factor_model_result Output from factor model function
#' @param asset_name Name of the asset for plot titles
plot_factor_model <- function(factor_model_result, asset_name = "Asset") {
  
  fitted_values <- factor_model_result$fitted_values
  residuals <- factor_model_result$residuals
  r_squared <- factor_model_result$r_squared
  
  # Set up plotting area
  par(mfrow = c(2, 2))
  
  # 1. Fitted vs Actual
  plot(fitted_values, fitted_values + residuals, 
       main = paste(asset_name, "- Fitted vs Actual Returns"),
       xlab = "Fitted Returns", ylab = "Actual Returns")
  abline(0, 1, col = "red", lwd = 2)
  legend("topleft", paste("R² =", round(r_squared, 3)), bty = "n")
  
  # 2. Residuals vs Fitted
  plot(fitted_values, residuals,
       main = "Residuals vs Fitted",
       xlab = "Fitted Returns", ylab = "Residuals")
  abline(h = 0, col = "red", lwd = 2)
  
  # 3. Q-Q plot of residuals
  qqnorm(residuals, main = "Q-Q Plot of Residuals")
  qqline(residuals, col = "red", lwd = 2)
  
  # 4. Residuals histogram
  hist(residuals, breaks = 20, main = "Distribution of Residuals",
       xlab = "Residuals", col = "lightblue", border = "white")
  
  # Reset plotting area
  par(mfrow = c(1, 1))
}

# Example usage
if (interactive()) {
  cat("Risk Factor Modeling Example\n")
  cat("============================\n\n")
  
  # Generate sample data
  set.seed(123)
  n_obs <- 252
  
  # Market factor
  market_returns <- rnorm(n_obs, mean = 0.0008, sd = 0.015)
  
  # Generate asset with factor exposure
  asset_beta <- 1.2
  asset_alpha <- 0.0002
  specific_risk <- rnorm(n_obs, mean = 0, sd = 0.01)
  asset_returns <- asset_alpha + asset_beta * market_returns + specific_risk
  
  # Fit single factor model
  capm_result <- single_factor_model(asset_returns, market_returns)
  
  cat("CAPM Results:\n")
  cat("Alpha:", round(capm_result$alpha * 252 * 100, 2), "% (annualized)\n")
  cat("Beta:", round(capm_result$beta, 3), "\n")
  cat("R-squared:", round(capm_result$r_squared, 3), "\n")
  cat("Tracking Error:", round(capm_result$tracking_error * sqrt(252) * 100, 2), "% (annualized)\n\n")
  
  # Plot results
  plot_factor_model(capm_result, "Sample Asset")
}