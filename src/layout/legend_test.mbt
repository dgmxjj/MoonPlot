///|
test "legend_layout_wraps_horizontal_entries_without_overlap" {
  let legend = LegendLayout::new(10.0, 20.0, 180.0)
    .set_flow(LegendFlow::Horizontal)
    .set_line_height(16.0)
    .set_gap(8.0)
    .add("latency", 70.0)
    .add("throughput", 90.0)
    .add("temperature", 100.0)
  let (x0, y0) = legend.item_position(0)
  let (x1, y1) = legend.item_position(1)
  let (x2, y2) = legend.item_position(2)
  assert_eq(x0, 10.0)
  assert_eq(y0, 20.0)
  assert_eq(x1, 88.0)
  assert_eq(y1, 20.0)
  assert_eq(x2, 10.0)
  assert_eq(y2, 44.0)
  assert_eq(legend.rows(), 2)
}

///|
test "legend_layout_handles_empty_and_invalid_entries" {
  let legend = LegendLayout::new(0.0, 0.0, 0.0)
    .set_line_height(-1.0)
    .set_gap(-3.0)
    .add("empty", -10.0)
  assert_eq(legend.entry_count(), 1)
  let (x, y) = legend.item_position(99)
  assert_eq(x, 0.0)
  assert_eq(y, 0.0)
  let (width, height) = legend.content_size()
  assert_eq(width, 0.0)
  assert_eq(height, 16.0)
}
