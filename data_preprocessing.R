# Data loading and preprocessing for Phishing Website Detection

# Clear environment
rm(list = ls())

# Set seed for reproducibility
set.seed(12345)

# Load data
load_and_preprocess_data <- function(file_path = "PhishingData.csv") {
  # Read data
  Phish <- read.csv(file_path)
  
  # Sample the data
  L <- as.data.frame(c(1:50))
  L <- L[sample(nrow(L), 10, replace = FALSE),]
  Phish <- Phish[(Phish$A01 %in% L),]
  PD <- Phish[sample(nrow(Phish), 2000, replace = FALSE),]
  
  # Data exploration
  cat("Dataset dimensions:", ncol(PD), "columns and", nrow(PD), "rows\n")
  
  # Display class distribution
  phishing_proportion <- table(PD$Class)
  cat("Class distribution:\n")
  print(phishing_proportion)
  
  # Data cleaning
  cat("Number of missing values:", sum(is.na(PD)), "\n")
  PD <- na.omit(PD)
  cat("Rows after removing missing values:", nrow(PD), "\n")
  
  # Convert class to factor
  PD$Class <- as.factor(PD$Class)
  
  return(PD)
}

# Split data into training and testing sets
split_data <- function(data, train_ratio = 0.7) {
  set.seed(12345)
  train_rows <- sample(1:nrow(data), train_ratio * nrow(data))
  train_data <- data[train_rows, ]
  test_data <- data[-train_rows, ]
  
  return(list(train = train_data, test = test_data))
}

# Visualize class distribution
visualize_class_distribution <- function(data) {
  phishing_proportion <- table(data$Class)
  labels <- c("Legitimate Sites", "Phishing Sites")
  percentages <- round(phishing_proportion / sum(phishing_proportion) * 100)
  percent_labels <- paste(labels, percentages, "%", sep=" ")
  
  pie(phishing_proportion, 
      labels = percent_labels, 
      col = c("lightblue", "lightcoral"), 
      main = "Proportion of Phishing to Legitimate Sites")
}

# Calculate descriptive statistics
calculate_descriptive_stats <- function(data) {
  descriptions <- data.frame(
    Min = sapply(data[, !names(data) %in% "Class"], min, na.rm = TRUE),
    `1st Quartile` = sapply(data[, !names(data) %in% "Class"], 
                            function(x) quantile(x, 0.25, na.rm = TRUE)),
    Median = sapply(data[, !names(data) %in% "Class"], median, na.rm = TRUE),
    Mean = sapply(data[, !names(data) %in% "Class"], mean, na.rm = TRUE),
    `3rd Quartile` = sapply(data[, !names(data) %in% "Class"], 
                            function(x) quantile(x, 0.75, na.rm = TRUE)),
    Max = sapply(data[, !names(data) %in% "Class"], max, na.rm = TRUE),
    Std = sapply(data[, !names(data) %in% "Class"], sd, na.rm = TRUE),
    num_na = sapply(data[, !names(data) %in% "Class"], function(x) sum(is.na(x)))
  )
  
  return(descriptions)
}

# If this script is run directly
if (!exists("CALLED_FROM_MAIN")) {
  # Load required packages
  source("requirements.R")
  
  # Process data
  data <- load_and_preprocess_data()
  
  # Visualize class distribution
  visualize_class_distribution(data)
  
  # Calculate and print descriptive statistics
  stats <- calculate_descriptive_stats(data)
  print(stats)
  
  # Split data
  data_split <- split_data(data)
  
  # Save for later use
  save(data_split, file = "processed_data.RData")
}