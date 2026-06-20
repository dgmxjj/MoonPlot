test "linear_scale" {
  let s = @coord.LinearScale::new(0.0, 10.0, 0.0, 100.0)
  assert_eq(s.map(5.0), 50.0)
}
