# Main script for Phishing Website Detection

# Set flag to prevent duplicate execution
CALLED_FROM_MAIN <- TRUE

# Load required packages
source("requirements.R")

# Data preprocessing
cat("\n--- Data Preprocessing ---\n")
source("data_preprocessing.R")
data <- load_and_preprocess_data()
data_split <- split_data(data)

# Show data summary
visualize_class_distribution(data)
data_summary <- calculate_descriptive_stats(data)
print(head(data_summary))

# Train models
cat("\n--- Model Training ---\n")
source("model_training.R")
dt_model <- train_decision_tree(data_split$train)
nb_model <- train_naive_bayes(data_split$train)
bagging_model <- train_bagging(data_split$train)
boosting_model <- train_boosting(data_split$train)
rf_model <- train_random_forest(data_split$train)
simple_model <- train_simplified_model(data_split$train)
nn_result <- train_neural_network(data_split$train)
nn_model <- nn_result$model
nn_predictors <- nn_result$predictors
xgb_model <- train_gradient_boosting(data_split$train)

cat("All models trained successfully.\n")

# Feature importance analysis
cat("\n--- Feature Importance Analysis ---\n")
source("feature_selection.R")
tree_importance <- get_tree_importance(dt_model)
rf_importance <- get_rf_importance(rf_model)
bagging_importance <- get_bagging_importance(bagging_model)
boosting_importance <- get_boosting_importance(boosting_model)

key_features <- find_key_features(
  tree_importance, 
  rf_importance, 
  bagging_importance, 
  boosting_importance
)

cat("Key features identified:", paste(key_features, collapse = ", "), "\n")

# Model evaluation
cat("\n--- Model Evaluation ---\n")
source("model_evaluation.R")
dt_eval <- evaluate_decision_tree(dt_model, data_split$test)
nb_eval <- evaluate_naive_bayes(nb_model, data_split$test)
bagging_eval <- evaluate_bagging(bagging_model, data_split$test)
boosting_eval <- evaluate_boosting(boosting_model, data_split$test)
rf_eval <- evaluate_random_forest(rf_model, data_split$test)
simple_eval <- evaluate_decision_tree(simple_model, data_split$test)
nn_eval <- evaluate_neural_network(nn_model, data_split$test, nn_predictors)
xgb_eval <- evaluate_gradient_boosting(xgb_model, data_split$test)

# Create evaluation list
evaluations <- list(
  "Decision Tree" = dt_eval,
  "Naive Bayes" = nb_eval,
  "Bagging" = bagging_eval,
  "Boosting" = boosting_eval,
  "Random Forest" = rf_eval,
  "Simple Model" = simple_eval,
  "Neural Network" = nn_eval,
  "Gradient Boosting" = xgb_eval
)

# Visualizations
cat("\n--- Visualizations ---\n")
source("visualization.R")
plot_roc_curves(evaluations)
plot_decision_tree(dt_model)
plot_simplified_tree(simple_model)
plot_feature_importance(rf_importance)

# Results summary
cat("\n--- Results Summary ---\n")
results_table <- create_results_table(evaluations)
print(results_table)

cat("\nPhishing website detection analysis complete.\n")