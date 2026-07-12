///|
fn main {
  let backend = @backend.SVGBackend::new(800.0, 600.0)
  let chart = @chart.ChartBuilder::new(backend)
    .set_title("MoonPlot - 柱状图与分类比例尺示例")
    .add_legend_item("销售额", @color.blue, "bar")
  let (x_min, y_min, x_max, y_max) = chart.get_plot_bounds()
  let categories = ["一季度", "二季度", "三季度", "四季度"]
  let scale_x = @coord.CategoryScale::new(categories, x_min, x_max)
  let scale_y = @coord.LinearScale::new(0.0, 100.0, y_max, y_min)
  chart.draw_title()
  chart.draw_legend()
  chart.draw_category_grid(scale_x, scale_y, 5)
  let axis_x = @chart.Axis::new("季度")
  let axis_y = @chart.Axis::new("销售额 (万元)")
  axis_x.draw_category_x_axis(backend, scale_x, x_min, x_max, y_max)
  axis_y.draw_y_axis(backend, scale_y, y_min, y_max, x_min)
  let data = [
    ("一季度", 45.0),
    ("二季度", 75.0),
    ("三季度", 90.0),
    ("四季度", 60.0),
  ]
  let bar_series = @series.BarSeries::new(data)
  bar_series.draw(backend, scale_x, scale_y)
  let svg = backend.to_string()
  println(svg)
}
