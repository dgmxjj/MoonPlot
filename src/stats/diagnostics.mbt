///|
/// Standardize values around the series mean. A constant series maps to zero
/// scores instead of exposing a divide-by-zero result.
pub fn NumericSeries::z_scores(self : NumericSeries) -> NumericSeries {
  let average = self.mean()
  let deviation = self.stddev()
  let output : Array[Double] = []
  for value in self.data {
    if deviation == 0.0 {
      output.push(0.0)
    } else {
      output.push((value - average) / deviation)
    }
  }
  NumericSeries::new(self.name + " (z-score)", output)
}

///|
/// Standard error of the mean, with a safe zero result for empty data.
pub fn NumericSeries::standard_error(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  self.stddev() / @math.pow(self.data.length().to_double(), 0.5)
}

///|
/// Pearson autocorrelation at a non-negative lag. A zero lag is one for a
/// non-empty series; invalid or too-large lags return zero.
pub fn NumericSeries::autocorrelation(self : NumericSeries, lag : Int) -> Double {
  let count = self.data.length()
  if lag < 0 || lag >= count {
    return 0.0
  }
  if lag == 0 {
    return if count == 0 { 0.0 } else { 1.0 }
  }
  let pair_count = count - lag
  if pair_count < 2 {
    return 0.0
  }
  let mut left_total = 0.0
  let mut right_total = 0.0
  for i = 0; i < pair_count; i = i + 1 {
    left_total = left_total + self.data[i]
    right_total = right_total + self.data[i + lag]
  }
  let left_mean = left_total / pair_count.to_double()
  let right_mean = right_total / pair_count.to_double()
  let mut covariance = 0.0
  let mut left_variance = 0.0
  let mut right_variance = 0.0
  for i = 0; i < pair_count; i = i + 1 {
    let left_delta = self.data[i] - left_mean
    let right_delta = self.data[i + lag] - right_mean
    covariance = covariance + left_delta * right_delta
    left_variance = left_variance + left_delta * left_delta
    right_variance = right_variance + right_delta * right_delta
  }
  if left_variance == 0.0 || right_variance == 0.0 {
    0.0
  } else {
    covariance / @math.pow(left_variance * right_variance, 0.5)
  }
}
