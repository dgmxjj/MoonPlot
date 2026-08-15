///|
/// The deterministic result of fitting `y = slope * x + intercept`.
pub(all) struct LinearRegression {
  slope : Double
  intercept : Double
  r_squared : Double
  sample_count : Int
  x_mean : Double
  y_mean : Double
}

///|
/// Fit a simple least-squares line. If the inputs have different lengths,
/// only the shared prefix is used. Empty, one-point, and constant-x inputs
/// return a safe horizontal model instead of dividing by zero.
pub fn LinearRegression::fit(
  x : Array[Double],
  y : Array[Double],
) -> LinearRegression {
  let count = if x.length() < y.length() { x.length() } else { y.length() }
  if count == 0 {
    return {
      slope: 0.0,
      intercept: 0.0,
      r_squared: 0.0,
      sample_count: 0,
      x_mean: 0.0,
      y_mean: 0.0,
    }
  }
  let mut x_total = 0.0
  let mut y_total = 0.0
  for i = 0; i < count; i = i + 1 {
    x_total = x_total + x[i]
    y_total = y_total + y[i]
  }
  let x_mean = x_total / count.to_double()
  let y_mean = y_total / count.to_double()
  let mut covariance = 0.0
  let mut x_variance = 0.0
  let mut y_variance = 0.0
  for i = 0; i < count; i = i + 1 {
    let x_delta = x[i] - x_mean
    let y_delta = y[i] - y_mean
    covariance = covariance + x_delta * y_delta
    x_variance = x_variance + x_delta * x_delta
    y_variance = y_variance + y_delta * y_delta
  }
  let slope = if x_variance == 0.0 { 0.0 } else { covariance / x_variance }
  let intercept = y_mean - slope * x_mean
  let mut residual_sum = 0.0
  for i = 0; i < count; i = i + 1 {
    let error = y[i] - (slope * x[i] + intercept)
    residual_sum = residual_sum + error * error
  }
  let r_squared = if y_variance == 0.0 {
    0.0
  } else {
    1.0 - residual_sum / y_variance
  }
  {
    slope,
    intercept,
    r_squared,
    sample_count: count,
    x_mean,
    y_mean,
  }
}

///|
pub fn LinearRegression::predict(self : LinearRegression, x : Double) -> Double {
  self.slope * x + self.intercept
}

///|
/// Return response residuals for the shared prefix of x and y.
pub fn LinearRegression::residuals(
  self : LinearRegression,
  x : Array[Double],
  y : Array[Double],
) -> Array[Double] {
  let count = if x.length() < y.length() { x.length() } else { y.length() }
  let output : Array[Double] = []
  for i = 0; i < count; i = i + 1 {
    output.push(y[i] - self.predict(x[i]))
  }
  output
}

///|
pub fn LinearRegression::mean_squared_error(
  self : LinearRegression,
  x : Array[Double],
  y : Array[Double],
) -> Double {
  let residuals = self.residuals(x, y)
  if residuals.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for error in residuals {
    total = total + error * error
  }
  total / residuals.length().to_double()
}

///|
pub fn NumericSeries::linear_regression(
  self : NumericSeries,
  x : Array[Double],
) -> LinearRegression {
  LinearRegression::fit(x, self.data)
}
