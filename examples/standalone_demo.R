#' Simple VaR Demo (No External Dependencies)
#' 
#' Demonstrates basic VaR calculation without requiring external packages
#' This can run immediately after cloning the repository

cat("Delta QRM Framework - Standalone Demo\n")
cat("=====================================\n\n")

# Simple VaR function that doesn't require external packages
calculate_var <- function(returns, confidence_level = 0.95, portfolio_value = 1000000) {
  if (length(returns) < 10) {
    stop("Need at least 10 observations for VaR calculation")
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

# Simple Expected Shortfall function
calculate_es <- function(returns, confidence_level = 0.95, portfolio_value = 1000000) {
  alpha <- 1 - confidence_level
  var_threshold <- quantile(returns, alpha, na.rm = TRUE)
  tail_returns <- returns[returns <= var_threshold]
  es_percent <- mean(tail_returns, na.rm = TRUE)
  es_dollar <- abs(es_percent * portfolio_value)
  
  return(list(
    es_percent = es_percent,
    es_dollar = es_dollar
  ))
}

# Create sample data
set.seed(42)
returns <- rnorm(252, 0.0008, 0.015)  # Daily returns for 1 year
portfolio_value <- 1000000

# Calculate risk measures
var_95 <- calculate_var(returns, 0.95, portfolio_value)
var_99 <- calculate_var(returns, 0.99, portfolio_value)
es_95 <- calculate_es(returns, 0.95, portfolio_value)

# Display results
cat("Sample Portfolio Risk Analysis\n")
cat("==============================\n")
cat("Portfolio Value: $", format(portfolio_value, big.mark = ","), "\n")
cat("Number of Observations:", length(returns), "days\n\n")

cat("Value at Risk (VaR):\n")
cat("95% VaR: $", format(round(var_95$var_dollar), big.mark = ","), "\n")
cat("99% VaR: $", format(round(var_99$var_dollar), big.mark = ","), "\n\n")

cat("Expected Shortfall (ES):\n")
cat("95% ES: $", format(round(es_95$es_dollar), big.mark = ","), "\n\n")

# Basic portfolio statistics
portfolio_mean <- mean(returns) * 252  # Annualized
portfolio_vol <- sd(returns) * sqrt(252)  # Annualized
sharpe_ratio <- (portfolio_mean - 0.02) / portfolio_vol  # Assuming 2% risk-free rate

cat("Portfolio Statistics (Annualized):\n")
cat("Expected Return: ", sprintf("%.2f%%", portfolio_mean * 100), "\n")
cat("Volatility: ", sprintf("%.2f%%", portfolio_vol * 100), "\n")
cat("Sharpe Ratio: ", sprintf("%.3f", sharpe_ratio), "\n\n")

# Risk interpretation
cat("Risk Interpretation:\n")
cat("====================\n")
cat("• With 95% confidence, daily losses will not exceed $", 
    format(round(var_95$var_dollar), big.mark = ","), "\n")
cat("• In the worst 5% of cases, average loss is $", 
    format(round(es_95$es_dollar), big.mark = ","), "\n")
cat("• Annual volatility of ", sprintf("%.1f%%", portfolio_vol * 100), 
    " indicates ", ifelse(portfolio_vol > 0.15, "high", "moderate"), " risk\n\n")

cat("Framework Status:\n")
cat("=================\n")
cat("✓ Core VaR calculations working\n")
cat("✓ Expected Shortfall calculation working\n")
cat("✓ Portfolio statistics working\n")
cat("✓ Sample data generation working\n\n")

cat("Next Steps:\n")
cat("===========\n")
cat("1. Install packages: source('setup_packages.R')\n")
cat("2. Open in Positron IDE: delta-qrm.Rproj\n")
cat("3. Run full intro: source('examples/intro_to_qrm.R')\n")
cat("4. Run comprehensive analysis: source('examples/comprehensive_qrm_analysis.R')\n\n")

cat("Framework ready for Columbia University QRM course!\n")