# Model evaluation for Phishing Website Detection

# Calculate accuracy from confusion matrix
calculate_accuracy <- function(confusion_matrix) {
  accuracy <- sum(diag(as.matrix(confusion_matrix))) / sum(confusion_matrix)
  return(accuracy)
}

# Evaluate Decision Tree
evaluate_decision_tree <- function(model, test_data) {
  predictions <- predict(model, test_data, type = "class")
  confusion <- table(Predicted_Class = predictions, Actual_Class = test_data$Class)
  
  # Calculate ROC
  pred_prob <- predict(model, test_data, type = "vector")
  pred_obj <- ROCR::prediction(pred_prob[, 2], test_data$Class)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Naive Bayes
evaluate_naive_bayes <- function(model, test_data) {
  predictions <- predict(model, test_data)
  confusion <- table(Predicted_Class = predictions, Actual_Class = test_data$Class)
  
  # Calculate ROC
  pred_prob <- predict(model, test_data, type = "raw")
  pred_obj <- ROCR::prediction(pred_prob[, 2], test_data$Class)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Bagging
evaluate_bagging <- function(model, test_data) {
  predictions <- predict.bagging(model, test_data)
  confusion <- predictions$confusion
  
  # Calculate ROC
  pred_obj <- ROCR::prediction(predictions$prob[, 2], test_data$Class)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Boosting
evaluate_boosting <- function(model, test_data) {
  predictions <- predict.boosting(model, test_data)
  confusion <- predictions$confusion
  
  # Calculate ROC
  pred_obj <- ROCR::prediction(predictions$prob[, 2], test_data$Class)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Random Forest
evaluate_random_forest <- function(model, test_data) {
  predictions <- predict(model, test_data)
  confusion <- table(Predicted_Class = predictions, Actual_Class = test_data$Class)
  
  # Calculate ROC
  pred_prob <- predict(model, test_data, type = "prob")
  pred_obj <- ROCR::prediction(pred_prob[, 2], test_data$Class)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Neural Network
evaluate_neural_network <- function(model, test_data, predictors) {
  # Prepare test data
  test_data_nn <- test_data
  test_data_nn[] <- lapply(test_data_nn, as.numeric)
  
  # Normalize data
  normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
  }
  
  test_data_norm <- as.data.frame(lapply(test_data_nn, normalize))
  
  # Make predictions
  predictions <- neuralnet::compute(model, test_data_norm[, predictors])
  predictions$net.result <- pmax(pmin(predictions$net.result, 1), 0)
  pred_df <- as.data.frame(predictions$net.result)
  pred_rounded <- as.data.frame(round(predictions$net.result, 0))
  
  confusion <- table(observed = test_data_norm$Class, 
                     predicted = pred_rounded$V1)
  
  # Calculate ROC
  pred_obj <- ROCR::prediction(pred_df, test_data_norm$Class)
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  perf <- performance(pred_obj, "tpr", "fpr")
  
  return(list(
    confusion = confusion,
    accuracy = calculate_accuracy(confusion),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Evaluate Gradient Boosting
evaluate_gradient_boosting <- function(model, test_data) {
  # Prepare test data
  test_data[] <- lapply(test_data, as.numeric)
  test_labels <- test_data$Class
  test_matrix <- as.matrix(test_data[, !names(test_data) %in% "Class"])
  dtest <- xgb.DMatrix(data = test_matrix, label = test_labels)
  
  # Make predictions
  pred_prob <- predict(model, dtest)
  pred_class <- ifelse(pred_prob > 0.5, 1, 0)
  
  confusion <- table(Predicted = pred_class, Actual = test_labels)
  
  # Calculate ROC
  pred_obj <- ROCR::prediction(pred_prob, test_labels)
  perf <- performance(pred_obj, "tpr", "fpr")
  roc_auc <- performance(pred_obj, measure = "auc")@y.values[[1]]
  
  return(list(
    confusion = confusion,
    accuracy = sum(pred_class == test_labels) / length(test_labels),
    roc_curve = perf,
    auc = roc_auc
  ))
}

# Compare all models
compare_models <- function(evaluation_results) {
  # Extract accuracies and AUCs
  accuracies <- sapply(evaluation_results, function(x) x$accuracy)
  aucs <- sapply(evaluation_results, function(x) x$auc)
  
  # Create comparison table
  results_table <- matrix(c(accuracies, aucs), nrow = 2, byrow = TRUE)
  rownames(results_table) <- c("Accuracy", "ROC AUC")
  colnames(results_table) <- names(evaluation_results)
  
  return(results_table)
}

# If this script is run directly
if (!exists("CALLED_FROM_MAIN")) {
  # Load required packages
  source("requirements.R")
  
  # Load models and data
  if (file.exists("trained_models.RData") && file.exists("processed_data.RData")) {
    load("trained_models.RData")
    load("processed_data.RData")
  } else {
    source("model_training.R")
    CALLED_FROM_MAIN <- TRUE
  }
  
  # Evaluate models
  dt_eval <- evaluate_decision_tree(dt_model, data_split$test)
  nb_eval <- evaluate_naive_bayes(nb_model, data_split$test)
  bagging_eval <- evaluate_bagging(bagging_model, data_split$test)
  boosting_eval <- evaluate_boosting(boosting_model, data_split$test)
  rf_eval <- evaluate_random_forest(rf_model, data_split$test)
  
  # Compare models
  evaluations <- list(
    "Decision Tree" = dt_eval,
    "Naive Bayes" = nb_eval,
    "Bagging" = bagging_eval,
    "Boosting" = boosting_eval,
    "Random Forest" = rf_eval
  )
  
  comparison <- compare_models(evaluations)
  print(comparison)
}