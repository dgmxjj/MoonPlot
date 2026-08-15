///|
test "advanced_report_is_deterministic_and_contains_analysis_markers" {
  let output = build_report()
  assert_true(output.contains("rows=4;columns=3"))
  assert_true(output.contains("groups=east=11.5,west=17"))
  assert_true(output.contains("slope=-0.18"))
  assert_true(output.contains("<rect"))
}
