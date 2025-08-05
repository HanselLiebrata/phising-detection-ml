# Model training for Phishing Website Detection

# Train Decision Tree model
train_decision_tree <- function(train_data) {
  model <- tree(Class ~ ., data = train_data)
  return(model)
}

# Train Naive Bayes model
train_naive_bayes <- function(train_data) {
  model <- naiveBayes(Class ~ ., data = train_data)
  return(model)
}

# Train Bagging model
train_bagging <- function(train_data) {
  model <- bagging(Class ~ ., data = train_data)
  return(model)
}

# Train Boosting model
train_boosting <- function(train_data) {
  model <- boosting(Class ~ ., data = train_data)
  return(model)
}

# Train Random Forest model
train_random_forest <- function(train_data) {
  model <- randomForest(Class ~ ., data = train_data, na.action = na.exclude)
  return(model)
}

# Train optimized Random Forest with cross-validation
train_optimized_rf <- function(train_data) {
  control <- trainControl(method = "cv", number = 5, search = "grid")
  tunegrid <- expand.grid(.mtry = c(1:15))
  set.seed(12345)
  
  rf_gridsearch <- train(Class ~ ., 
                         data = train_data, 
                         method = "rf", 
                         tuneGrid = tunegrid, 
                         trControl = control)
  
  return(rf_gridsearch$finalModel)
}

# Train simplified model with key features
train_simplified_model <- function(train_data) {
  model <- tree(Class ~ A01 + A18 + A23, data = train_data)
  return(model)
}

# Train neural network model
train_neural_network <- function(train_data, hidden_layers = 3) {
  # Prepare data for neural network
  train_data_nn <- train_data
  train_data_nn[] <- lapply(train_data_nn, as.numeric)
  
  # Normalize data
  normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
  }
  
  train_data_norm <- as.data.frame(lapply(train_data_nn, normalize))
  
  # Select predictors
  predictors <- c("A01", "A18", "A23", "A22", "A08")
  
  # Train neural network
  set.seed(12345)
  model <- neuralnet(Class ~ A01 + A18 + A23 + A22 + A08, 
                     train_data_norm, 
                     hidden = hidden_layers, 
                     linear.output = FALSE, 
                     stepmax = 1e6)
  
  return(list(model = model, predictors = predictors))
}

# Train gradient boosting model
train_gradient_boosting <- function(train_data) {
  # Convert data
  train_data[] <- lapply(train_data, as.numeric)
  
  # Prepare data for xgboost
  train_labels <- train_data$Class
  train_matrix <- as.matrix(train_data[, !names(train_data) %in% "Class"])
  
  dtrain <- xgb.DMatrix(data = train_matrix, label = train_labels)
  
  # Set parameters
  params <- list(
    objective = "binary:logistic",
    eval_metric = "error",
    max_depth = 6,
    eta = 0.3,
    nthread = 2
  )
  
  # Train model
  xgb_model <- xgb.train(
    params = params,
    data = dtrain,
    nrounds = 100,
    watchlist = list(train = dtrain),
    verbose = 0
  )
  
  return(xgb_model)
}

# If this script is run directly
if (!exists("CALLED_FROM_MAIN")) {
  # Load required packages
  source("requirements.R")
  
  # Load processed data
  if (file.exists("processed_data.RData")) {
    load("processed_data.RData")
  } else {
    source("data_preprocessing.R")
    CALLED_FROM_MAIN <- TRUE
    data <- load_and_preprocess_data()
    data_split <- split_data(data)
  }
  
  # Train models
  dt_model <- train_decision_tree(data_split$train)
  nb_model <- train_naive_bayes(data_split$train)
  bagging_model <- train_bagging(data_split$train)
  boosting_model <- train_boosting(data_split$train)
  rf_model <- train_random_forest(data_split$train)
  
  # Save models
  save(dt_model, nb_model, bagging_model, boosting_model, rf_model,
       file = "trained_models.RData")
}