///|
/// A deterministic report pipeline combining table profiling, grouped
/// summaries, regression diagnostics, and a heatmap render.
pub fn build_report() -> String {
  let csv =
    "region,throughput,latency\neast,100,12\neast,120,11\nwest,80,18\nwest,90,16\n"
  let table = @data.CsvTable::parse(csv).unwrap()
  let profile = table.profile()
  let groups = table.group_numeric("region", "latency").unwrap()
  let throughput = table.numeric_column("throughput").unwrap()
  let latency = table.numeric_column("latency").unwrap()
  let model = @stats.NumericSeries::new("latency", latency).linear_regression(throughput)
  let matrix = [
    [100.0, 12.0, model.predict(100.0)],
    [120.0, 11.0, model.predict(120.0)],
    [80.0, 18.0, model.predict(80.0)],
    [90.0, 16.0, model.predict(90.0)],
  ]
  let backend = @backend.SVGBackend::new(480.0, 280.0)
  let scale_x = @coord.LinearScale::new(0.0, 3.0, 40.0, 440.0)
  let scale_y = @coord.LinearScale::new(0.0, 4.0, 240.0, 40.0)
  @series.HeatmapSeries::new(matrix)
    .set_domain(0.0, 120.0)
    .set_colors(@color.light_gray, @color.blue)
    .draw(backend, scale_x, scale_y)
  let group_text = groups.map(fn(group) { "\{group.key}=\{group.mean}" }).join(",")
  "rows=\{profile.row_count};columns=\{profile.column_count};groups=\{group_text};slope=\{model.slope};\n\{backend.to_string()}"
}
