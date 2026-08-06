///|
test "linear_scale" {
  let s = @coord.LinearScale::new(0.0, 10.0, 0.0, 100.0)
  assert_eq(s.map(5.0), 50.0)

  let trait_scale : &@coord.Scale = s
  assert_eq(trait_scale.map(5.0), 50.0)
}

///|
test "logarithmic_scale" {
  let s = @coord.LogarithmicScale::new(1.0, 100.0, 0.0, 100.0)
  assert_eq(s.map(1.0), 0.0)
  assert_eq(s.map(10.0), 50.0)
  assert_eq(s.map(100.0), 100.0)

  let trait_scale : &@coord.Scale = s
  assert_eq(trait_scale.map(10.0), 50.0)
}

///|
test "category_scale" {
  let s = @coord.CategoryScale::new(["A", "B", "C"], 0.0, 120.0)
  assert_eq(s.map("A"), 20.0)
  assert_eq(s.map("B"), 60.0)
  assert_eq(s.map("C"), 100.0)
  assert_eq(s.map("missing"), 0.0)
  let empty = @coord.CategoryScale::new([], 7.0, 9.0)
  assert_eq(empty.map("missing"), 7.0)
}

///|
test "scale_tick_and_mapping_boundaries" {
  let linear = @coord.LinearScale::new(0.0, 10.0, 0.0, 100.0)
  assert_eq(linear.map(0.0), 0.0)
  assert_eq(linear.map(10.0), 100.0)
  assert_eq(linear.generate_ticks(0), [])
  assert_eq(linear.generate_ticks(1), [])
  let constant = @coord.LinearScale::new(5.0, 5.0, 20.0, 80.0)
  assert_eq(constant.map(99.0), 20.0)
}
