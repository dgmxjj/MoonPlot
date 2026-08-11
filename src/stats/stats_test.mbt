///|
test "numeric_series_summary_is_deterministic" {
  let series = NumericSeries::new("latency", [1.0, 2.0, 3.0, 4.0, 5.0])
  let summary = series.summary()
  assert_eq(summary.count, 5)
  assert_eq(summary.min, 1.0)
  assert_eq(summary.max, 5.0)
  assert_eq(summary.mean, 3.0)
  assert_eq(summary.median, 3.0)
  assert_eq(summary.variance, 2.0)
}

///|
test "numeric_series_supports_quantiles_histogram_and_normalization" {
  let series = NumericSeries::new("throughput", [10.0, 20.0, 30.0, 40.0])
  assert_eq(series.quantile(0.25), 17.5)
  let normalized = series.normalize()
  assert_eq(normalized.values()[0], 0.0)
  assert_eq(normalized.values()[1], 0.3333333333333333)
  assert_eq(normalized.values()[2], 0.6666666666666666)
  assert_eq(normalized.values()[3], 1.0)
  let bins = series.histogram(2)
  assert_eq(bins.length(), 2)
  assert_eq(bins[0].count, 2)
  assert_eq(bins[1].count, 2)
}

///|
test "numeric_series_handles_windows_and_correlation_boundaries" {
  let series = NumericSeries::new("temperature", [1.0, 2.0, 3.0, 4.0])
  let average = series.moving_average(2).values()
  assert_eq(average[0], 1.0)
  assert_eq(average[1], 1.5)
  assert_eq(average[2], 2.5)
  assert_eq(average[3], 3.5)
  assert_eq(series.moving_average(0).values().length(), 0)
  assert_eq(
    series.correlation(NumericSeries::new("other", [2.0, 4.0, 6.0, 8.0])),
    1.0,
  )
  assert_eq(
    series.correlation(NumericSeries::new("constant", [1.0, 1.0, 1.0, 1.0])),
    0.0,
  )
}

///|
test "empty_numeric_series_has_safe_summary" {
  let summary = NumericSeries::new("empty", []).summary()
  assert_eq(summary.count, 0)
  assert_eq(summary.mean, 0.0)
  assert_eq(summary.min, 0.0)
  assert_eq(summary.max, 0.0)
}

///|
test "numeric_series_transformations_are_total" {
  let series = NumericSeries::new("signal", [-2.0, 1.0, 4.0])
  let clipped = series.clip(3.0, -1.0).values()
  assert_eq(clipped[0], -1.0)
  assert_eq(clipped[1], 1.0)
  assert_eq(clipped[2], 3.0)
  assert_eq(series.scale(2.0).values()[2], 8.0)
  assert_eq(series.shift(1.0).values()[0], -1.0)
  assert_eq(series.difference().values()[0], 0.0)
  assert_eq(series.difference().values()[2], 3.0)
  assert_eq(series.take(99).length(), 3)
  assert_eq(series.take(-1).length(), 0)
  assert_eq(series.slice(1, 99).values()[0], 1.0)
}

///|
test "histogram_handles_constant_and_invalid_bin_inputs" {
  let constant = NumericSeries::new("constant", [4.0, 4.0, 4.0])
  let bins = constant.histogram(4)
  assert_eq(bins.length(), 1)
  assert_eq(bins[0].count, 3)
  assert_eq(constant.histogram(0).length(), 0)
}

///|
test "robust_statistics_find_outliers_and_window_extrema" {
  let series = NumericSeries::new("latency", [1.0, 2.0, 2.0, 3.0, 20.0])
  assert_eq(series.median_absolute_deviation(), 1.0)
  let outliers = series.outlier_indices(3.0)
  assert_eq(outliers.length(), 1)
  assert_eq(outliers[0], 4)
  let minimums = series.rolling_min(3).values()
  let maximums = series.rolling_max(3).values()
  assert_eq(minimums[3], 2.0)
  assert_eq(maximums[4], 20.0)
}

///|
test "resampling_preserves_endpoints_and_small_inputs" {
  let series = NumericSeries::new("trend", [0.0, 10.0, 20.0, 30.0])
  let sampled = series.resample(3).values()
  assert_eq(sampled[0], 0.0)
  assert_eq(sampled[1], 15.0)
  assert_eq(sampled[2], 30.0)
  assert_eq(series.resample(1).values()[0], 0.0)
  assert_eq(series.resample(0).length(), 0)
}

///|
test "series_aggregates_support_monitoring_reports" {
  let series = NumericSeries::new("load", [2.0, 4.0, 8.0])
  let cumulative = series.cumulative_sum().values()
  assert_eq(cumulative[0], 2.0)
  assert_eq(cumulative[2], 14.0)
  let change = series.percent_change().values()
  assert_eq(change[0], 0.0)
  assert_eq(change[1], 100.0)
  let ema = series.exponential_moving_average(0.5).values()
  assert_eq(ema[0], 2.0)
  assert_eq(ema[2], 5.5)
  assert_eq(series.summary().range(), 6.0)
  assert_true(series.summary().coefficient_of_variation() > 0.5)
}
