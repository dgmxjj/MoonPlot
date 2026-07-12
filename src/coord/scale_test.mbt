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
}
