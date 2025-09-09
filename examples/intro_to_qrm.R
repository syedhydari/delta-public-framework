#' Introduction to Delta QRM Framework
#' 
#' Quick start guide for using the Delta Quantitative Risk Management Framework
#' in Positron IDE for Columbia University coursework.

cat("=================================================\n")
cat("Delta Quantitative Risk Management Framework\n")
cat("Columbia University - Educational Use\n")
cat("=================================================\n\n")

cat("Welcome to the Delta QRM Framework!\n\n")

cat("This framework provides R tools for quantitative risk management including:\n")
cat("• Value at Risk (VaR) calculations\n")
cat("• Portfolio optimization\n")
cat("• Monte Carlo simulations\n")
cat("• Risk factor modeling\n")
cat("• Stress testing\n\n")

cat("Getting Started:\n")
cat("================\n")
cat("1. Install required packages: source('setup_packages.R')\n")
cat("2. Explore the R/ directory for core functions\n")
cat("3. Run examples: source('examples/comprehensive_qrm_analysis.R')\n")
cat("4. Check docs/ directory for detailed documentation\n\n")

cat("Main R Modules:\n")
cat("===============\n")
cat("• R/var_analysis.R - Value at Risk calculations\n")
cat("• R/portfolio_optimization.R - Mean-variance optimization\n")
cat("• R/monte_carlo.R - Monte Carlo simulations\n")
cat("• R/risk_factors.R - Factor model analysis\n\n")

cat("Example Usage:\n")
cat("==============\n")
cat("# Load VaR functions\n")
cat("source('R/var_analysis.R')\n\n")
cat("# Calculate 95% VaR for sample returns\n")
cat("sample_returns <- rnorm(252, 0.0008, 0.02)\n")
cat("var_result <- historical_var(sample_returns, 0.95, 1000000)\n")
cat("print(var_result)\n\n")

cat("For Positron IDE Users:\n")
cat("=======================\n")
cat("• Open delta-qrm.Rproj to activate the project\n")
cat("• Use the integrated terminal for R commands\n")
cat("• Explore data/ directory for sample datasets\n")
cat("• View plots in the Plots pane\n")
cat("• Use the Environment pane to track variables\n\n")

cat("Educational Notes:\n")
cat("==================\n")
cat("This framework is designed for learning quantitative risk management.\n")
cat("All code is provided for educational purposes and includes:\n")
cat("• Detailed comments explaining methodology\n")
cat("• Examples with synthetic data\n")
cat("• Step-by-step analysis workflows\n")
cat("• Integration with modern R practices\n\n")

cat("Next Steps:\n")
cat("===========\n")
cat("1. Run: source('setup_packages.R') to install dependencies\n")
cat("2. Then: source('examples/comprehensive_qrm_analysis.R') for full demo\n")
cat("3. Explore individual modules in the R/ directory\n")
cat("4. Create your own analysis scripts\n\n")

cat("Happy risk modeling!\n")
cat("=================================================\n")