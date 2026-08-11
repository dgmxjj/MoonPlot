///|
/// A reproducible benchmark example using a versioned subset of UCI Iris.
fn main {
  let csv = "sepal_length,sepal_width,petal_length,petal_width,species\n5.1,3.5,1.4,0.2,Iris-setosa\n4.9,3.0,1.4,0.2,Iris-setosa\n4.7,3.2,1.3,0.2,Iris-setosa\n4.6,3.1,1.5,0.2,Iris-setosa\n5.0,3.6,1.4,0.2,Iris-setosa\n5.4,3.9,1.7,0.4,Iris-setosa\n4.6,3.4,1.4,0.3,Iris-setosa\n5.0,3.4,1.5,0.2,Iris-setosa\n7.0,3.2,4.7,1.4,Iris-versicolor\n6.4,3.2,4.5,1.5,Iris-versicolor\n6.9,3.1,4.9,1.5,Iris-versicolor\n5.5,2.3,4.0,1.3,Iris-versicolor\n6.5,2.8,4.6,1.5,Iris-versicolor\n5.7,2.8,4.5,1.3,Iris-versicolor\n6.3,3.3,6.0,2.5,Iris-virginica\n5.8,2.7,5.1,1.9,Iris-virginica\n7.1,3.0,5.9,2.1,Iris-virginica\n6.3,2.9,5.6,1.8,Iris-virginica"
  let table = @data.CsvTable::parse(csv).unwrap()
  let values = @stats.NumericSeries::new(
    "petal width",
    table.numeric_column("petal_width").unwrap(),
  )
  let summary = values.summary()
  let backend = @backend.SVGBackend::new(720.0, 440.0)
  let chart = @chart.ChartBuilder::new(backend)
    .set_title("UCI Iris petal width (n=\{summary.count})")
    .add_legend_item("mean=\{summary.mean}", @color.blue, "line")
  let (x_min, y_min, x_max, y_max) = chart.get_plot_bounds()
  let safe_max = if summary.max > summary.min {
    summary.max
  } else {
    summary.min + 1.0
  }
  let scale_x = @coord.LinearScale::new(
    0.0,
    (values.length() - 1).to_double(),
    x_min,
    x_max,
  )
  let scale_y = @coord.LinearScale::new(summary.min, safe_max, y_max, y_min)
  let points : Array[(Double, Double)] = []
  let data = values.values()
  for i = 0; i < data.length(); i = i + 1 {
    points.push((i.to_double(), data[i]))
  }
  chart.draw_title()
  chart.draw_legend()
  chart.draw_grid(scale_x, scale_y, 6, 5)
  @chart.Axis::new("sample").draw_x_axis(backend, scale_x, x_min, x_max, y_max)
  @chart.Axis::new("petal width (cm)").draw_y_axis(
    backend, scale_y, y_min, y_max, x_min,
  )
  @series.LineSeries::new(points)
  .set_color(@color.blue)
  .draw(backend, scale_x, scale_y)
  println(backend.to_string())
}
