///|
test "series_diagnostics_cover_z_scores_and_autocorrelation" {
  let series = NumericSeries::new("signal", [1.0, 2.0, 3.0, 4.0])
  let z = series.z_scores().values()
  assert_true(z[0] < -1.0)
  assert_true(z[3] > 1.0)
  assert_eq(series.autocorrelation(1), 1.0)
  assert_eq(series.autocorrelation(0), 1.0)
  assert_eq(series.standard_error(), 0.5590169943749475)
}

///|
test "series_diagnostics_are_safe_for_constant_empty_and_invalid_lags" {
  let constant = NumericSeries::new("constant", [2.0, 2.0])
  assert_eq(constant.z_scores().values()[0], 0.0)
  assert_eq(constant.autocorrelation(1), 0.0)
  assert_eq(constant.autocorrelation(-1), 0.0)
  assert_eq(NumericSeries::new("empty", []).standard_error(), 0.0)
}
