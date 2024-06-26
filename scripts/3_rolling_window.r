rolling_window <- function(fn, df, nwindow = 1, horizon, variable, ...) {
  # nwindow: out-of-sample size
  window_size <- nrow(df) - nwindow - horizon + 1
  indmat <- matrix(NA, window_size, nwindow)
  indmat[1, ] <- seq_len(ncol(indmat))
  for (i in 2:nrow(indmat)) {
    indmat[i, ] <- indmat[i - 1, ] + 1
  }

  rw <- apply(
    X = indmat,
    MARGIN = 2,
    FUN = fn,
    df = df,
    horizon = horizon,
    variable = variable,
    ...
  )

  forecast <- unlist(lapply(rw, function(x) x$forecast))
  var_imp <- lapply(rw, function(x) x$outputs$var_imp)

  return(
    list(
      forecast = forecast,
      var_imp = var_imp
    )
  )
}
