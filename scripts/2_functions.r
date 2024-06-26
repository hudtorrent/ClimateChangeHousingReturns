# Packages

library(tidyverse)

##################################################################

# Building the dataset

f_data <- function(ind) {
  # ind: dataset indexes. Response is m1.
  # we go until m6.

  text_1 <- paste(
    "cbind(",
    paste(
      "m",
      ind,
      collapse = ",",
      sep = ""
    ),
    ")",
    sep = ""
  )

  res <- eval(parse(text = text_1))

  return(as.matrix(res))
}

##################################################################

# Model name

f_model_name <- function(ind, n_lags, for_hor, nwindows, pad) {
  if (pad) {
    pad_aux <- "pad"
  } else {
    pad_aux <- "non_pad"
  }
  if (min(ind) != 1) {
    stop("m1 must be included!")
  } else if (length(ind) == 1) {
    model_name <- paste(
      "housing_m1",
      "_L", # lags
      n_lags,
      "_h", # forecast horizon
      for_hor,
      "_oos_",
      nwindows,
      "_",
      pad_aux,
      sep = ""
    )
  } else if (length(ind) > 1) {
    model_name <- paste(
      "housing_m",
      min(ind),
      "_to_m",
      max(ind),
      "_L", # lags
      n_lags,
      "_h", # forecast horizon
      for_hor,
      "_oos_",
      nwindows,
      "_",
      pad_aux,
      sep = ""
    )
  }
  return(model_name)
}

##################################################################

# RMSE

f_rmse <- function(x, y) {
  sqrt(mean((x - y)^2))
}

##################################################################

# CSFE

f_csfe <- function(x, y_bench, y_real) {
  error_bench <- (y_bench - y_real)^2
  error_x <- (x - y_real)^2
  result <- cumsum(error_bench - error_x)
  return(result)
}

##################################################################

# Boosting

f_boosting <- function(ind, df, variable, horizon, n_lags) {
  library(mboost)
  library(forecast)

  # INICIALIZACAO DE VARIAVEIS
  set.seed(100)

  data_in <- dataprep(
    ind = ind,
    df = df,
    variable = variable,
    horizon = horizon,
    n_lags = n_lags
  )

  y_in <- data_in$y_in
  x_in <- data_in$x_in
  x_out <- data_in$x_out

  # AJUSTE DO MODELO DE BOOSTING
  reg_full <- glmboost(
    y = y_in,
    x = as.matrix(x_in),
    offset = 0,
    center = TRUE,
    control = boost_control(mstop = 300, nu = 0.1)
  )

  # DETERMINACAO DO NUMERO OTIMO DE ITERACOES
  cv5f <- cv(model.weights(reg_full), type = "kfold", B = 5)
  cv_seq <- cvrisk(reg_full, folds = cv5f, papply = lapply)
  m_opt <- mstop(cv_seq)

  # AJUSTE DO MODELO COM O NUMERO OTIMO DE ITERACOES

  reg_opt <- reg_full[m_opt]

  # PREVISAO PARA A JANELA DE TESTE
  opt_boosting <- predict(
    object = reg_opt,
    newdata = matrix(x_out, nrow = 1)
  ) %>% as.vector() + mean(y_in)

  # RESULTADOS
  results <- list(
    forecast = opt_boosting,
    outputs = list(
      m_opt = m_opt,
      var_imp = varimp(reg_opt),
      reg_opt = reg_opt
    )
  )
  return(results)
}

##################################################################

# Boosting (standardized)

f_boosting_pad <- function(ind, df, variable, horizon, n_lags) {
  library(mboost)
  library(forecast)

  # INICIALIZACAO DE VARIAVEIS
  set.seed(100)

  data_in <- dataprep(
    ind = ind,
    df = df,
    variable = variable,
    horizon = horizon,
    n_lags = n_lags
  )

  y_in <- f_pad(data_in$y_in)
  my_in <- mean(data_in$y_in)
  sy_in <- sd(data_in$y_in)

  x_in <- apply(data_in$x_in, 2, f_pad)
  mx_in <- apply(data_in$x_in, 2, mean)
  sx_in <- apply(data_in$x_in, 2, sd)

  x_out <- (data_in$x_out - mx_in) / sx_in

  # AJUSTE DO MODELO DE BOOSTING
  reg_full <- glmboost(
    y = y_in,
    x = as.matrix(x_in),
    offset = 0,
    center = TRUE,
    control = boost_control(mstop = 300, nu = 0.1)
  )

  # DETERMINACAO DO NUMERO OTIMO DE ITERACOES
  cv5f <- cv(model.weights(reg_full), type = "kfold", B = 5)
  cv_seq <- cvrisk(reg_full, folds = cv5f, papply = lapply)
  m_opt <- mstop(cv_seq)

  # AJUSTE DO MODELO COM O NUMERO OTIMO DE ITERACOES

  reg_opt <- reg_full[m_opt]

  # PREVISAO PARA A JANELA DE TESTE
  opt_boosting <- predict(
    object = reg_opt,
    newdata = matrix(x_out, nrow = 1)
  ) %>% as.vector() * sy_in + my_in

  # RESULTADOS
  results <- list(
    forecast = opt_boosting,
    outputs = list(
      m_opt = m_opt,
      var_imp = varimp(reg_opt),
      reg_opt = reg_opt
    )
  )
  return(results)
}

##################################################################

# Function to standardize a variable

f_pad <- function(x) {
  mx <- mean(x)
  sx <- sd(x)
  y <- (x - mx) / sx

  return(y)
}

##################################################################
