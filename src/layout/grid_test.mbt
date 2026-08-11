///|
test "panel_grid_calculates_non_overlapping_panels" {
  let grid = PanelGrid::new(2, 2, 400.0, 300.0)
    .set_gap(20.0, 10.0)
    .set_margins(20.0, 20.0, 20.0, 20.0)
  assert_eq(grid.panel_count(), 4)
  let first = grid.panel(0)
  let second = grid.panel(1)
  assert_eq(first.width, 170.0)
  assert_eq(first.height, 125.0)
  assert_eq(second.x, 210.0)
  assert_true(first.right() < second.x)
  assert_true(first.bottom() > 0.0)
}

///|
test "panel_grid_clamps_invalid_dimensions_and_indices" {
  let grid = PanelGrid::new(0, -2, 80.0, 60.0).set_gap(100.0, 100.0)
  assert_eq(grid.rows(), 1)
  assert_eq(grid.columns(), 1)
  assert_eq(grid.panel_count(), 1)
  let rect = grid.panel(99)
  assert_eq(rect.width, 0.0)
  assert_eq(rect.height, 0.0)
}

///|
test "panel_grid_finds_a_responsive_column_count" {
  assert_eq(PanelGrid::columns_for_width(900.0, 240.0, 20.0), 3)
  assert_eq(PanelGrid::columns_for_width(100.0, 240.0, 20.0), 1)
  assert_eq(PanelGrid::columns_for_width(900.0, 0.0, 20.0), 1)
}
