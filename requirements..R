# List of required packages for the Phishing Website Detection project
required_packages <- c(
  "tree",
  "e1071",
  "ROCR",
  "randomForest",
  "adabag",
  "rpart",
  "dplyr",
  "caret",
  "neuralnet",
  "xgboost"
)

# Function to install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
  
  # Load all packages
  lapply(packages, library, character.only = TRUE)
}

# Install and load packages
install_if_missing(required_packages)