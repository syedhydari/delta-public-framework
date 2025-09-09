#' Sample Financial Data for QRM Framework
#' 
#' This script creates sample datasets for educational purposes
#' in quantitative risk management analysis.

# Create sample daily returns data
set.seed(42)  # For reproducible results

# Sample 1: Daily returns for 4-asset portfolio (2 years of data)
n_days <- 504
asset_names <- c("US_Large_Cap", "US_Small_Cap", "International", "Bonds")

# Expected annual returns
expected_returns <- c(0.10, 0.12, 0.08, 0.04)

# Annual volatilities
volatilities <- c(0.15, 0.22, 0.18, 0.05)

# Correlation matrix
correlations <- matrix(c(
  1.00, 0.80, 0.70, 0.20,
  0.80, 1.00, 0.65, 0.15,
  0.70, 0.65, 1.00, 0.25,
  0.20, 0.15, 0.25, 1.00
), nrow = 4, byrow = TRUE)

# Generate correlated returns
library(MASS)
daily_expected <- expected_returns / 252
daily_vols <- volatilities / sqrt(252)
cov_matrix <- diag(daily_vols) %*% correlations %*% diag(daily_vols)

sample_returns <- mvrnorm(n = n_days, mu = daily_expected, Sigma = cov_matrix)
colnames(sample_returns) <- asset_names

# Create dates (business days only)
start_date <- as.Date("2022-01-03")
dates <- seq.Date(start_date, by = "day", length.out = n_days * 1.4)
business_days <- dates[weekdays(dates) %in% c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")]
dates <- business_days[1:n_days]

# Create data frame
portfolio_returns_sample <- data.frame(
  Date = dates,
  sample_returns
)

# Sample 2: Market factors data
market_returns <- sample_returns[, 1] + rnorm(n_days, 0, 0.002)  # Market proxy
risk_free_rate <- rep(0.02/252, n_days)  # 2% annual risk-free rate

market_factors_sample <- data.frame(
  Date = dates,
  Market = market_returns,
  Risk_Free = risk_free_rate,
  SMB = rnorm(n_days, 0, 0.005),  # Size factor
  HML = rnorm(n_days, 0, 0.004)   # Value factor
)

# Sample 3: Economic indicators
economic_indicators_sample <- data.frame(
  Date = dates,
  VIX = pmax(10, 20 + 15 * rnorm(n_days, 0, 1)),  # Volatility index
  Term_Spread = pmax(0, 2 + rnorm(n_days, 0, 0.5)), # Term spread
  Credit_Spread = pmax(0, 1 + rnorm(n_days, 0, 0.3)), # Credit spread
  USD_Index = 100 + cumsum(rnorm(n_days, 0, 0.5))  # US Dollar index
)

# Save datasets
save(portfolio_returns_sample, file = "data/portfolio_returns_sample.RData")
save(market_factors_sample, file = "data/market_factors_sample.RData") 
save(economic_indicators_sample, file = "data/economic_indicators_sample.RData")

# Create CSV files for broader compatibility
write.csv(portfolio_returns_sample, "data/portfolio_returns_sample.csv", row.names = FALSE)
write.csv(market_factors_sample, "data/market_factors_sample.csv", row.names = FALSE)
write.csv(economic_indicators_sample, "data/economic_indicators_sample.csv", row.names = FALSE)

cat("Sample datasets created:\n")
cat("========================\n")
cat("1. portfolio_returns_sample.RData/.csv - Daily returns for 4 assets\n")
cat("2. market_factors_sample.RData/.csv - Market factors (Fama-French style)\n")
cat("3. economic_indicators_sample.RData/.csv - Economic indicators\n\n")

cat("Dataset summaries:\n")
cat("Portfolio Returns Sample:\n")
print(summary(portfolio_returns_sample[, -1]))
cat("\nMarket Factors Sample:\n")
print(summary(market_factors_sample[, -1]))
cat("\nEconomic Indicators Sample:\n")
print(summary(economic_indicators_sample[, -1]))

cat("\nData creation complete! Files saved to data/ directory.\n")