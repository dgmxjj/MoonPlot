///|
test "dashboard_layout_allocates_named_panels_without_overlap" {
  let dashboard = Dashboard::new(640.0, 360.0, 2, 2)
    .add_panel("latency")
    .add_panel("throughput")
    .add_panel("errors")
  assert_eq(dashboard.panel_count(), 3)
  assert_eq(dashboard.panel(0).title, "latency")
  assert_true(dashboard.panel(0).bounds.right() <= dashboard.panel(1).bounds.x)
  assert_true(dashboard.panel(2).bounds.y > dashboard.panel(0).bounds.y)
  assert_eq(dashboard.content_bounds().width, 640.0)
}

///|
test "dashboard_layout_clamps_invalid_grid_and_panel_indices" {
  let dashboard = Dashboard::new(0.0, -1.0, 0, 0)
  assert_eq(dashboard.panel_count(), 0)
  let bounds = dashboard.content_bounds()
  assert_eq(bounds.width, 1.0)
  assert_eq(bounds.height, 1.0)
}
