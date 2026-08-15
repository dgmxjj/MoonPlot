///|
test "area_series_includes_baseline_and_renders_negative_values" {
  let area = @series.AreaSeries::new([(0.0, -2.0), (1.0, 3.0), (2.0, 1.0)])
    .set_baseline(0.0)
    .set_color(@color.blue)
  let (x_min, y_min, x_max, y_max) = area.bounds()
  assert_eq(x_min, 0.0)
  assert_eq(y_min, -2.0)
  assert_eq(x_max, 2.0)
  assert_eq(y_max, 3.0)
  let backend = @backend.SVGBackend::new(200.0, 120.0)
  let scale_x = @coord.LinearScale::new(0.0, 2.0, 0.0, 200.0)
  let scale_y = @coord.LinearScale::new(-2.0, 3.0, 100.0, 0.0)
  area.draw(backend, scale_x, scale_y)
  assert_true(backend.to_string().contains("<polygon"))
}

///|
test "area_series_empty_and_invalid_baseline_are_safe" {
  let empty = @series.AreaSeries::new([]).set_baseline(4.0)
  let (x_min, y_min, x_max, y_max) = empty.bounds()
  assert_eq(x_min, 0.0)
  assert_eq(y_min, 0.0)
  assert_eq(x_max, 0.0)
  assert_eq(y_max, 0.0)
  let backend = @backend.SVGBackend::new(80.0, 80.0)
  let scale = @coord.LinearScale::new(0.0, 1.0, 80.0, 0.0)
  empty.draw(backend, scale, scale)
  assert_true(!backend.to_string().contains("<polygon"))
}

///|
test "heatmap_series_clamps_dimensions_and_maps_colors" {
  let heatmap = @series.HeatmapSeries::new([[0.0, 1.0], [2.0, 4.0]]).set_domain(
    0.0, 4.0,
  )
  assert_eq(heatmap.rows(), 2)
  assert_eq(heatmap.columns(), 2)
  assert_eq(heatmap.cell(0, 1), 1.0)
  assert_eq(heatmap.cell(-1, 0), 0.0)
  let backend = @backend.SVGBackend::new(200.0, 100.0)
  let scale_x = @coord.LinearScale::new(0.0, 2.0, 0.0, 200.0)
  let scale_y = @coord.LinearScale::new(0.0, 2.0, 100.0, 0.0)
  heatmap.draw(backend, scale_x, scale_y)
  assert_eq(backend.element_count(), 4)
  assert_true(backend.to_string().contains("rgba(0,0,255"))
}

///|
test "heatmap_series_handles_empty_ragged_and_constant_inputs" {
  let empty = @series.HeatmapSeries::new([])
  assert_eq(empty.rows(), 0)
  assert_eq(empty.columns(), 0)
  let ragged = @series.HeatmapSeries::new([[1.0, 2.0], [3.0]])
  assert_eq(ragged.columns(), 2)
  assert_eq(ragged.cell(1, 1), 0.0)
  let constant = @series.HeatmapSeries::new([[5.0]]).set_domain(5.0, 5.0)
  let backend = @backend.SVGBackend::new(20.0, 20.0)
  let scale = @coord.LinearScale::new(0.0, 1.0, 20.0, 0.0)
  constant.draw(backend, scale, scale)
  assert_eq(backend.element_count(), 1)
}
