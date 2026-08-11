///|
test "bar_series_handles_zero_and_negative_values" {
  let backend = @backend.SVGBackend::new(200.0, 120.0)
  let scale_x = @coord.CategoryScale::new(["negative", "zero"], 0.0, 200.0)
  let scale_y = @coord.LinearScale::new(-20.0, 20.0, 100.0, 0.0)
  let data = [("negative", -10.0), ("zero", 0.0)]
  @series.BarSeries::new(data).draw(backend, scale_x, scale_y)
  let svg = backend.to_string()
  assert_true(svg.contains("y=\"50\""))
  assert_true(svg.contains("height=\"25\""))
  assert_true(svg.contains("y=\"50\" width=\"80\" height=\"0\""))
}

///|
test "scatter_series_renders_all_point_styles" {
  let scale = @coord.LinearScale::new(0.0, 1.0, 0.0, 100.0)
  let points = [(0.5, 0.5)]
  let circle = @series.ScatterSeries::new(points)
  let square = { ..circle, style: @series.PointStyle::Square }
  let cross = { ..circle, style: @series.PointStyle::Cross }
  let backend = @backend.SVGBackend::new(100.0, 100.0)
  circle.draw(backend, scale, scale)
  square.draw(backend, scale, scale)
  cross.draw(backend, scale, scale)
  let svg = backend.to_string()
  assert_true(svg.contains("<circle"))
  assert_true(svg.contains("<rect"))
  assert_true(svg.contains("<line"))
}

///|
test "series_with_empty_data_emits_no_shapes" {
  let backend = @backend.SVGBackend::new(100.0, 100.0)
  let scale = @coord.LinearScale::new(0.0, 1.0, 0.0, 100.0)
  @series.LineSeries::new([]).draw(backend, scale, scale)
  @series.ScatterSeries::new([]).draw(backend, scale, scale)
  let svg = backend.to_string()
  assert_true(!svg.contains("<line"))
  assert_true(!svg.contains("<circle"))
}

///|
test "series_configuration_and_bounds_are_reusable" {
  let line = @series.LineSeries::new([(2.0, 8.0), (-1.0, 3.0)])
    .set_width(-4.0)
    .set_smooth(true)
  assert_eq(line.width, 0.0)
  assert_eq(line.is_smooth(), true)
  let (line_x_min, line_y_min, line_x_max, line_y_max) = line.bounds()
  assert_eq(line_x_min, -1.0)
  assert_eq(line_y_min, 3.0)
  assert_eq(line_x_max, 2.0)
  assert_eq(line_y_max, 8.0)

  let bar = @series.BarSeries::new([("A", -3.0), ("B", 7.0)])
    .set_bar_width(2.0)
    .set_color(@color.blue)
  assert_eq(bar.bar_width, 1.0)
  let (bar_min, bar_max) = bar.bounds()
  assert_eq(bar_min, -3.0)
  assert_eq(bar_max, 7.0)

  let scatter = @series.ScatterSeries::new([(1.0, 4.0), (5.0, -2.0)])
    .set_radius(-1.0)
    .set_style(@series.PointStyle::Square)
  assert_eq(scatter.radius, 0.0)
  let (scatter_x_min, scatter_y_min, scatter_x_max, scatter_y_max) = scatter.bounds()
  assert_eq(scatter_x_min, 1.0)
  assert_eq(scatter_y_min, -2.0)
  assert_eq(scatter_x_max, 5.0)
  assert_eq(scatter_y_max, 4.0)
}

///|
test "stacked_bars_keep_positive_and_negative_baselines_separate" {
  let backend = @backend.SVGBackend::new(240.0, 160.0)
  let scale_x = @coord.CategoryScale::new(["A", "B"], 0.0, 240.0)
  let scale_y = @coord.LinearScale::new(-4.0, 6.0, 140.0, 0.0)
  let stacked = @series.StackedBarSeries::new([
    ("A", [2.0, 3.0]),
    ("B", [-1.0, 2.0]),
  ])
  assert_eq(stacked.category_count(), 2)
  assert_eq(stacked.segment_count(), 2)
  let (low, high) = stacked.bounds()
  assert_eq(low, -1.0)
  assert_eq(high, 5.0)
  stacked.draw(backend, scale_x, scale_y)
  assert_eq(backend.element_count(), 4)
}
