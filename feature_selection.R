# Feature selection and importance analysis for Phishing Website Detection

# Extract feature importance from Decision Tree
get_tree_importance <- function(tree_model) {
  importance <- summary(tree_model)$used
  return(importance)
}

# Extract feature importance from Random Forest
get_rf_importance <- function(rf_model) {
  importance <- rf_model$importance
  return(importance)
}

# Extract feature importance from Bagging
get_bagging_importance <- function(bagging_model) {
  importance <- bagging_model$importance
  return(importance)
}

# Extract feature importance from Boosting
get_boosting_importance <- function(boosting_model) {
  importance <- boosting_model$importance
  return(importance)
}

# Extract feature importance from optimized Random Forest
get_optimized_rf_importance <- function(rf_gridsearch) {
  importance <- varImp(rf_gridsearch, scale = FALSE)
  return(importance)
}

# Find most important features across models
find_key_features <- function(tree_imp, rf_imp, bagging_imp, boosting_imp) {
  # Combine importance scores
  all_features <- unique(c(
    names(tree_imp)[tree_imp > 0],
    names(rf_imp)[rf_imp > median(rf_imp)],
    names(bagging_imp)[bagging_imp > median(bagging_imp)],
    names(boosting_imp)[boosting_imp > median(boosting_imp)]
  ))
  
  # Count appearances across models
  feature_counts <- sapply(all_features, function(feature) {
    count <- 0
    if (feature %in% names(tree_imp) && tree_imp[feature] > 0) count <- count + 1
    if (feature %in% names(rf_imp) && rf_imp[feature] > median(rf_imp)) count <- count + 1
    if (feature %in% names(bagging_imp) && bagging_imp[feature] > median(bagging_imp)) count <- count + 1
    if (feature %in% names(boosting_imp) && boosting_imp[feature] > median(boosting_imp)) count <- count + 1
    return(count)
  })
  
  # Get features that appear in at least 3 models
  key_features <- names(feature_counts)[feature_counts >= 3]
  
  return(key_features)
}

# If this script is run directly
if (!exists("CALLED_FROM_MAIN")) {
  # Load required packages
  source("requirements.R")
  
  # Load models
  if (file.exists("trained_models.RData")) {
    load("trained_models.RData")
  } else {
    source("model_training.R")
    CALLED_FROM_MAIN <- TRUE
  }
  
  # Get feature importance
  tree_importance <- get_tree_importance(dt_model)
  rf_importance <- get_rf_importance(rf_model)
  bagging_importance <- get_bagging_importance(bagging_model)
  boosting_importance <- get_boosting_importance(boosting_model)
  
  # Find key features
  key_features <- find_key_features(
    tree_importance, 
    rf_importance, 
    bagging_importance, 
    boosting_importance
  )
  
  cat("Key features identified:", paste(key_features, collapse = ", "), "\n")
}