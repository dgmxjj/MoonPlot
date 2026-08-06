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
