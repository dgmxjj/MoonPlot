///|
test "box_plot_series_computes_quartiles_and_renders_whiskers" {
  let plot = @series.BoxPlotSeries::new(1.0, [1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(plot.minimum(), 1.0)
  assert_eq(plot.lower_quartile(), 2.0)
  assert_eq(plot.median(), 3.0)
  assert_eq(plot.upper_quartile(), 4.0)
  assert_eq(plot.maximum(), 5.0)
  let backend = @backend.SVGBackend::new(100.0, 120.0)
  let x = @coord.LinearScale::new(0.0, 2.0, 0.0, 100.0)
  let y = @coord.LinearScale::new(0.0, 5.0, 100.0, 0.0)
  plot.draw(backend, x, y)
  assert_true(backend.element_count() >= 5)
}

///|
test "box_plot_series_handles_empty_and_invalid_width" {
  let plot = @series.BoxPlotSeries::new(0.0, []).set_width(-2.0)
  assert_eq(plot.width(), 0.0)
  assert_eq(plot.minimum(), 0.0)
  assert_eq(plot.maximum(), 0.0)
  let backend = @backend.SVGBackend::new(20.0, 20.0)
  let scale = @coord.LinearScale::new(0.0, 1.0, 20.0, 0.0)
  plot.draw(backend, scale, scale)
  assert_eq(backend.element_count(), 0)
}
