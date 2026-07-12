///|
test "color_blend" {
  let c1 = @color.rgba(255, 0, 0, 1.0)
  let c2 = @color.rgba(0, 0, 255, 1.0)
  let c3 = @color.blend(c1, c2, 0.5)
  assert_eq(c3.r, 127)
  assert_eq(c3.b, 127)
}
