///|
test "svg_chart_rendering_validation" {
  let backend = @backend.SVGBackend::new(600.0, 400.0)
  let chart = @chart.ChartBuilder::new(backend)
    .set_title("Test Title")
    .add_legend_item("Benchmark", @color.red, "line")
  let (x_min, y_min, x_max, y_max) = chart.get_plot_bounds()
  let scale_x = @coord.LinearScale::new(0.0, 10.0, x_min, x_max)
  let scale_y = @coord.LinearScale::new(0.0, 100.0, y_max, y_min)
  chart.draw_title()
  chart.draw_legend()
  chart.draw_grid(scale_x, scale_y, 5, 5)
  let axis_x = @chart.Axis::new("X Axis")
  let axis_y = @chart.Axis::new("Y Axis")
  axis_x.draw_x_axis(backend, scale_x, x_min, x_max, y_max)
  axis_y.draw_y_axis(backend, scale_y, y_min, y_max, x_min)
  let points = [(1.0, 10.0), (5.0, 50.0), (9.0, 90.0)]
  let line = @series.LineSeries::new(points).set_color(@color.red)
  line.draw(backend, scale_x, scale_y)
  let svg_str = backend.to_string()
  assert_eq(svg_str.contains("<svg width=\"600\" height=\"400\""), true)
  assert_eq(svg_str.contains("Test Title"), true)
  assert_eq(svg_str.contains("X Axis"), true)
  assert_eq(svg_str.contains("Y Axis"), true)
  assert_eq(svg_str.contains("<line "), true)
  assert_eq(svg_str.contains("<text "), true)
}

///|
test "chart_layout_separates_plot_and_long_legend" {
  let backend = @backend.SVGBackend::new(400.0, 240.0)
  let chart = @chart.ChartBuilder::new(backend)
    .set_title("Layout")
    .set_show_grid(false)
    .add_legend_item("A deliberately long series name", @color.blue, "line")
  let layout = chart.layout()
  let (x_min, _, x_max, _) = layout.plot_bounds()
  let (legend_x, _) = layout.legend_origin()
  assert_true(x_min < x_max)
  assert_true(x_max < legend_x)
  let scale_x = @coord.LinearScale::new(0.0, 1.0, x_min, x_max)
  let scale_y = @coord.LinearScale::new(0.0, 1.0, 100.0, 0.0)
  chart.draw_grid(scale_x, scale_y, 4, 4)
  assert_true(!backend.to_string().contains("rgba(220,220,220,0.8)"))
}

///|
test "chart_layout_keeps_a_positive_plot_for_small_canvas" {
  let backend = @backend.SVGBackend::new(120.0, 120.0)
  let chart = @chart.ChartBuilder::new(backend).add_legend_item(
    "A long legend entry", @color.blue, "line",
  )
  let (x_min, y_min, x_max, y_max) = chart.layout().plot_bounds()
  assert_true(x_min < x_max)
  assert_true(y_min < y_max)
}
