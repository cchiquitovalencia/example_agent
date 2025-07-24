# Package Installation Script for MDVRPTWH Shiny Application
# Author: AI Assistant

cat("Installing required R packages for MDVRPTWH Solver...\n\n")

# Create user library directory if it doesn't exist
user_lib <- Sys.getenv("R_LIBS_USER")
if (user_lib == "") {
  user_lib <- file.path(Sys.getenv("HOME"), "R", R.version$platform, 
                        paste(R.version$major, substr(R.version$minor, 1, 1), sep = "."))
}

if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE)
  cat("Created user library directory:", user_lib, "\n")
}

# Set library path
.libPaths(c(user_lib, .libPaths()))

# List of required packages
required_packages <- c(
  "shiny",
  "shinydashboard", 
  "dplyr",
  "plotly",
  "RColorBrewer",
  "DT",
  "testthat"
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  
  if(length(new_packages)) {
    cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE, lib = user_lib,
                     repos = "https://cran.rstudio.com/")
    cat("Installation complete!\n")
  } else {
    cat("All required packages are already installed.\n")
  }
}

# Install packages
tryCatch({
  install_if_missing(required_packages)
  
  # Verify installation
  cat("\nVerifying package installation...\n")
  for (pkg in required_packages) {
    if (require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat("✓", pkg, "successfully loaded\n")
    } else {
      cat("✗", pkg, "failed to load\n")
    }
  }
  
  cat("\nPackage installation verification complete!\n")
  cat("You can now run the application with: shiny::runApp()\n")
  
}, error = function(e) {
  cat("Error during installation:", e$message, "\n")
  cat("You may need to install packages manually or run with sudo.\n")
})