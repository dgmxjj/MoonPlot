///|
fn main {
  let backend = @backend.SVGBackend::new(800.0, 600.0)
  let chart = @chart.ChartBuilder::new(backend)
    .set_title("MoonPlot - 折线图示例")
    .add_legend_item("折线 1", @color.blue, "line")
    .add_legend_item("折线 2", @color.red, "line")
  let layout = chart.layout()
  let (x_min, y_min, x_max, y_max) = layout.plot_bounds()
  let scale_x = @coord.LinearScale::new(0.0, 10.0, x_min, x_max)
  let scale_y = @coord.LinearScale::new(0.0, 100.0, y_max, y_min)
  chart.draw_title()
  chart.draw_legend()
  chart.draw_grid(scale_x, scale_y, 6, 6)
  let axis_x = @chart.Axis::new("时间 (s)")
  let axis_y = @chart.Axis::new("数值")
  axis_x.draw_x_axis(backend, scale_x, x_min, x_max, y_max)
  axis_y.draw_y_axis(backend, scale_y, y_min, y_max, x_min)
  let data1 = [
    (0.0, 10.0),
    (2.0, 30.0),
    (4.0, 45.0),
    (6.0, 35.0),
    (8.0, 60.0),
    (10.0, 90.0),
  ]
  let series1 = @series.LineSeries::new(data1).set_color(@color.blue)
  series1.draw(backend, scale_x, scale_y)
  let data2 = [
    (0.0, 80.0),
    (2.0, 65.0),
    (4.0, 50.0),
    (6.0, 55.0),
    (8.0, 40.0),
    (10.0, 20.0),
  ]
  let series2 = @series.LineSeries::new(data2).set_color(@color.red)
  series2.draw(backend, scale_x, scale_y)
  let svg = backend.to_string()
  println(svg)
}
