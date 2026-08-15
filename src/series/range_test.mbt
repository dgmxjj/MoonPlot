///|
test "range_series_draws_a_band_and_reports_combined_bounds" {
  let range = @series.RangeSeries::new([
    (0.0, 1.0, 3.0),
    (1.0, 2.0, 5.0),
    (2.0, 0.0, 4.0),
  ])
  let (x_min, y_min, x_max, y_max) = range.bounds()
  assert_eq(x_min, 0.0)
  assert_eq(y_min, 0.0)
  assert_eq(x_max, 2.0)
  assert_eq(y_max, 5.0)
  let backend = @backend.SVGBackend::new(200.0, 100.0)
  let x = @coord.LinearScale::new(0.0, 2.0, 0.0, 200.0)
  let y = @coord.LinearScale::new(0.0, 5.0, 100.0, 0.0)
  range.draw(backend, x, y)
  assert_true(backend.to_string().contains("<polygon"))
  assert_true(backend.to_string().contains("<line"))
  assert_true(backend.element_count() >= 3)
}

///|
test "range_series_sanitizes_reversed_and_empty_ranges" {
  let range = @series.RangeSeries::new([(1.0, 5.0, 2.0)]).set_opacity(2.0)
  let values = range.values()
  assert_eq(values[0].1, 2.0)
  assert_eq(values[0].2, 5.0)
  assert_eq(range.opacity(), 1.0)
  let backend = @backend.SVGBackend::new(20.0, 20.0)
  let scale = @coord.LinearScale::new(0.0, 1.0, 20.0, 0.0)
  @series.RangeSeries::new([]).draw(backend, scale, scale)
  assert_eq(backend.element_count(), 0)
}
