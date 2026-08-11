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
  assert_eq(linear.generate_ticks(0).length(), 0)
  assert_eq(linear.generate_ticks(1).length(), 0)
  let constant = @coord.LinearScale::new(5.0, 5.0, 20.0, 80.0)
  assert_eq(constant.map(99.0), 20.0)
}

///|
test "numeric_domain_autoscaling_produces_nice_ticks" {
  let domain = @coord.NumericDomain::from_values([-2.0, 3.0, 7.0])
  assert_eq(domain.min(), -2.0)
  assert_eq(domain.max(), 7.0)
  assert_eq(domain.span(), 9.0)
  assert_true(domain.contains(0.0))
  let padded = domain.pad(0.1)
  assert_eq(padded.min(), -2.9)
  assert_eq(padded.max(), 7.9)
  let nice = @coord.NumericDomain::new(0.3, 9.7).nice(5)
  assert_eq(nice.min(), 0.0)
  assert_eq(nice.max(), 10.0)
  assert_eq(nice.ticks(5).length(), 5)
}

///|
test "numeric_domain_handles_empty_and_reversed_inputs" {
  let empty = @coord.NumericDomain::from_values([])
  assert_eq(empty.min(), 0.0)
  assert_eq(empty.max(), 1.0)
  let reversed = @coord.NumericDomain::new(10.0, -2.0)
  assert_eq(reversed.min(), -2.0)
  assert_eq(reversed.max(), 10.0)
}
