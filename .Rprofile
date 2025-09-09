# .Rprofile for Delta Quantitative Risk Management Framework
# Columbia University - Quantitative Risk Management Class

# Set CRAN mirror
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org/"
  options(repos = r)
})

# Enhanced error reporting
options(
  error = function() traceback(2),
  warn = 1,
  digits = 7,
  scipen = 999  # Avoid scientific notation for financial calculations
)

# Load commonly used packages silently
.First <- function() {
  cat("\nDelta Quantitative Risk Management Framework\n")
  cat("Columbia University - Educational Use\n")
  cat("===============================================\n\n")
  
  # Check if renv is available and activate
  if (file.exists("renv/activate.R")) {
    source("renv/activate.R")
    cat("renv activated for reproducible package management\n\n")
  }
  
  # Load essential packages if available
  essential_packages <- c("here", "tidyverse", "quantmod", "PerformanceAnalytics")
  for (pkg in essential_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    }
  }
}

# Positron IDE specific settings
if (Sys.getenv("POSITRON") != "") {
  cat("Positron IDE detected - optimizing settings\n")
  options(
    positron.viewer.auto_open = TRUE,
    positron.plot.auto_show = TRUE
  )
}