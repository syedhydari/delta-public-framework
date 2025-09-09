# Required R Packages for Delta QRM Framework
# ==========================================

# Install required packages for quantitative risk management
required_packages <- c(
  "tidyverse",        # Data manipulation and visualization
  "quantmod",         # Financial data and modeling
  "PerformanceAnalytics", # Portfolio performance analysis
  "MASS",             # Statistical functions
  "quadprog",         # Quadratic programming for optimization
  "broom",            # Model output tidying
  "moments",          # Statistical moments
  "tseries",          # Time series analysis
  "lmtest",           # Linear model testing
  "here",             # File path management
  "renv"              # Package management
)

# Function to install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, repos = "https://cloud.r-project.org/")
  } else {
    cat("All required packages are already installed.\n")
  }
}

# Install missing packages
install_if_missing(required_packages)

# Load essential packages
suppressPackageStartupMessages({
  library(here)
  if (requireNamespace("renv", quietly = TRUE)) {
    library(renv)
    cat("renv package management available\n")
  }
})

cat("Package setup complete!\n")
cat("Run source('examples/comprehensive_qrm_analysis.R') to start the analysis.\n")