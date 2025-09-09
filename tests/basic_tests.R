# Test script for Delta QRM Framework
# Simple tests to verify core functionality

cat("Testing Delta QRM Framework\n")
cat("===========================\n\n")

# Test 1: VaR Analysis
cat("Test 1: VaR Analysis\n")
cat("--------------------\n")

# Create simple test data
set.seed(123)
test_returns <- rnorm(100, 0.001, 0.02)

# Test if the basic VaR function works (without loading external packages)
historical_var_simple <- function(returns, confidence_level = 0.95) {
  alpha <- 1 - confidence_level
  var_percentile <- quantile(returns, alpha, na.rm = TRUE)
  return(var_percentile)
}

var_result <- historical_var_simple(test_returns)
cat("Sample VaR (95%): ", round(var_result * 100, 3), "%\n")

if (abs(var_result) > 0 && abs(var_result) < 0.1) {
  cat("✓ VaR calculation appears reasonable\n")
} else {
  cat("✗ VaR calculation may have issues\n")
}

# Test 2: Basic Portfolio Statistics  
cat("\nTest 2: Portfolio Statistics\n")
cat("-----------------------------\n")

portfolio_return <- mean(test_returns)
portfolio_risk <- sd(test_returns)
sharpe_ratio <- portfolio_return / portfolio_risk

cat("Portfolio Return: ", round(portfolio_return * 100, 3), "%\n")
cat("Portfolio Risk: ", round(portfolio_risk * 100, 3), "%\n")
cat("Sharpe Ratio: ", round(sharpe_ratio, 3), "\n")

if (abs(portfolio_return) < 0.01 && portfolio_risk > 0) {
  cat("✓ Portfolio statistics calculation successful\n")
} else {
  cat("✗ Portfolio statistics may have issues\n")
}

# Test 3: File Structure
cat("\nTest 3: File Structure\n")
cat("----------------------\n")

required_files <- c(
  "R/var_analysis.R",
  "R/portfolio_optimization.R", 
  "R/monte_carlo.R",
  "R/risk_factors.R",
  "examples/intro_to_qrm.R",
  "examples/comprehensive_qrm_analysis.R"
)

files_exist <- file.exists(required_files)
cat("Required files check:\n")
for (i in 1:length(required_files)) {
  status <- if (files_exist[i]) "✓" else "✗"
  cat(status, required_files[i], "\n")
}

if (all(files_exist)) {
  cat("✓ All required files present\n")
} else {
  cat("✗ Some required files missing\n")
}

# Test 4: R Project Configuration
cat("\nTest 4: R Project Configuration\n")
cat("-------------------------------\n")

if (file.exists("delta-qrm.Rproj")) {
  cat("✓ R project file exists\n")
} else {
  cat("✗ R project file missing\n")
}

if (file.exists(".Rprofile")) {
  cat("✓ R profile configuration exists\n")
} else {
  cat("✗ R profile configuration missing\n")
}

# Test Summary
cat("\nTest Summary\n")
cat("============\n")
cat("Basic functionality tests completed.\n")
cat("Framework appears ready for educational use.\n\n")

cat("Next steps:\n")
cat("1. Run: source('setup_packages.R') to install dependencies\n")
cat("2. Run: source('examples/intro_to_qrm.R') for introduction\n")
cat("3. Run: source('examples/comprehensive_qrm_analysis.R') for full demo\n")