///|
test "linear_regression_fits_predicts_and_scores" {
  let model = LinearRegression::fit([1.0, 2.0, 3.0, 4.0], [3.0, 5.0, 7.0, 9.0])
  assert_eq(model.sample_count, 4)
  assert_eq(model.slope, 2.0)
  assert_eq(model.intercept, 1.0)
  assert_eq(model.predict(5.0), 11.0)
  assert_eq(model.r_squared, 1.0)
  assert_eq(model.mean_squared_error([1.0, 2.0], [3.0, 5.0]), 0.0)
}

///|
test "linear_regression_handles_mismatched_and_degenerate_inputs" {
  let model = LinearRegression::fit([1.0, 2.0, 3.0], [4.0, 8.0])
  assert_eq(model.sample_count, 2)
  assert_eq(model.slope, 4.0)
  assert_eq(model.residuals([1.0, 2.0, 3.0], [4.0, 8.0]).length(), 2)
  let constant_x = LinearRegression::fit([2.0, 2.0], [4.0, 8.0])
  assert_eq(constant_x.slope, 0.0)
  assert_eq(constant_x.intercept, 6.0)
  assert_eq(constant_x.r_squared, 0.0)
  let empty = LinearRegression::fit([], [])
  assert_eq(empty.sample_count, 0)
  assert_eq(empty.predict(12.0), 0.0)
  assert_eq(empty.mean_squared_error([], []), 0.0)
}

///|
test "numeric_series_regression_uses_series_as_response" {
  let series = NumericSeries::new("latency", [10.0, 12.0, 14.0])
  let model = series.linear_regression([1.0, 2.0, 3.0])
  assert_eq(model.slope, 2.0)
  assert_eq(model.intercept, 8.0)
  assert_eq(model.residuals([1.0, 2.0], [10.0, 12.0]).length(), 2)
}
