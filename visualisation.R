# Visualization functions for Phishing Website Detection

# Plot ROC curves for all models
plot_roc_curves <- function(model_evaluations) {
  # Set up plot
  plot(model_evaluations[[1]]$roc_curve, 
       col = "orange", 
       main = "ROC Curves for Various Models")
  abline(0, 1)
  
  # Add other curves
  colors <- c("orange", "blueviolet", "blue", "red", "darkgreen", "purple", "cyan")
  for (i in 2:length(model_evaluations)) {
    plot(model_evaluations[[i]]$roc_curve, add = TRUE, col = colors[i])
  }
  
  # Add legend
  legend("bottomright", 
         legend = names(model_evaluations), 
         col = colors[1:length(model_evaluations)], 
         lty = 1)
}

# Plot decision tree
plot_decision_tree <- function(tree_model, title = "Decision Tree Model") {
  plot(tree_model, main = "")
  text(tree_model, pretty = 0)
  title(title)
}

# Plot simplified tree
plot_simplified_tree <- function(simple_model) {
  plot(simple_model, main = "")
  text(simple_model, pretty = 0)
  title("Simple Classifier")
}

# Plot feature importance
plot_feature_importance <- function(rf_importance, top_n = 10) {
  # Sort importance values
  sorted_imp <- sort(rf_importance, decreasing = TRUE)
  
  # Select top N features
  top_features <- sorted_imp[1:min(top_n, length(sorted_imp))]
  
  # Create barplot
  barplot(top_features, 
          main = "Top Feature Importance", 
          xlab = "Importance", 
          horiz = TRUE, 
          col = "steelblue",
          las = 1,
          cex.names = 0.8)
}

# Create comparison results table
create_results_table <- function(model_evaluations) {
  # Extract accuracies
  accuracies <- sapply(model_evaluations, function(x) x$accuracy)
  
  # Extract AUC values
  aucs <- sapply(model_evaluations, function(x) x$auc)
  
  # Create table
  results <- data.frame(
    Model = names(model_evaluations),
    Accuracy = round(accuracies, 4),
    AUC = round(aucs, 4)
  )
  
  # Sort by accuracy
  results <- results[order(-results$Accuracy), ]
  
  return(results)
}

# If this script is run directly
if (!exists("CALLED_FROM_MAIN")) {
  # Load required packages
  source("requirements.R")
  
  # Load models and evaluations
  if (!exists("dt_eval")) {
    source("model_evaluation.R")
    CALLED_FROM_MAIN <- TRUE
  }
  
  # Create evaluation list
  evaluations <- list(
    "Decision Tree" = dt_eval,
    "Naive Bayes" = nb_eval,
    "Bagging" = bagging_eval,
    "Boosting" = boosting_eval,
    "Random Forest" = rf_eval
  )
  
  # Plot ROC curves
  plot_roc_curves(evaluations)
  
  # Plot decision tree
  plot_decision_tree(dt_model)
  
  # Create results table
  results_table <- create_results_table(evaluations)
  print(results_table)
}