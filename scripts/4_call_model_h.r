rm(list = ls())

time_sta <- Sys.time()

# Models, forecast horizon and lags

ind_models <- 1:6
for_hor <- 48
n_lags <- 1
pad <- TRUE

# Auxiliar files

source("scripts/1_data_prep.r")
source("scripts/2_functions.r")
source("scripts/3_rolling_window.r")

# Loading the datasets

response <- read.csv("datasets/Long/housing_returns.csv", sep = ";", dec = ",")
dates <- response$Date
m1 <- select(response, Y)
m2 <- read.csv("datasets/Long/1macro_financial.csv", sep = ";", dec = ",")
m3 <- read.csv("datasets/Long/2eco_fin_uncert.csv", sep = ";", dec = ",")
m4 <- read.csv("datasets/Long/3non_eco_fin_uncert.csv", sep = ";", dec = ",")
m5 <- read.csv("datasets/Long/4climate_change.csv", sep = ";", dec = ",")
m6 <- read.csv("datasets/Long/5climate_change_vol.csv", sep = ";", dec = ",")

# Rolling window exercise

if (pad) {
  model_function <- f_boosting_pad
} else {
  model_function <- f_boosting
}

y_var <- "Y"
n_windows <- 516 # out-of-sample size

## Auxiliar objects

forecast_mat <- matrix(NA, nrow = n_windows, ncol = length(ind_models))
colnames(forecast_mat) <- paste(
  "yh_m",
  ind_models,
  "_L",
  n_lags,
  "_h",
  for_hor,
  sep = ""
)

var_imp_list <- vector(mode = "list", length = length(ind_models))
names(var_imp_list) <- paste(
  "m",
  ind_models,
  "_L",
  n_lags,
  "_h",
  for_hor,
  sep = ""
)

csfe_mat <- var_imp_list

## Loop

for (i in ind_models) {

  model_name <- f_model_name(ind_models[1:i], n_lags, for_hor, n_windows, pad)
  dados <- f_data(ind = ind_models[1:i])
  y_out <- tail(dados[, y_var], n_windows)

  ## Estimation

  model <- rolling_window(
    fn = model_function,
    df = dados,
    nwindow = n_windows,
    horizon = for_hor,
    variable = y_var,
    n_lags = n_lags
  )

  ## Results worth saving

  forecast_mat[, i] <- model$forecast %>% as.matrix()
  var_imp_list[[i]] <- model$var_imp

  ## Results temp

  rmse <- f_rmse(forecast_mat[, i], y = y_out) %>% print()

  csfe_mat[[i]] <- f_csfe(
    x = forecast_mat[, i],
    y_bench = forecast_mat[, 1],
    y_real = y_out
  )

}

# plot - temp

plot.ts(y_out)
for (i in ind_models) {
  lines(forecast_mat[, i], col = i + 1, lty = 1)
}

plot.ts(csfe_mat[[1]], ylim = range(unlist(csfe_mat)))
for (i in ind_models) {
  lines(csfe_mat[[i]], col = i)
}

# Saving

save(
  var_imp_list,
  forecast_mat,
  csfe_mat,
  y_out,
  file = paste(
    "results/h",
    for_hor,
    "/",
    model_name,
    ".rda",
    sep = ""
  )
)

time_end <- Sys.time()

print(time_end - time_sta)
