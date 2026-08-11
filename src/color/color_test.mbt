///|
test "color_blend" {
  let c1 = @color.rgba(255, 0, 0, 1.0)
  let c2 = @color.rgba(0, 0, 255, 1.0)
  let c3 = @color.blend(c1, c2, 0.5)
  assert_eq(c3.r, 127)
  assert_eq(c3.b, 127)
}

///|
test "palette_is_deterministic_and_supports_gradients" {
  let colors = palette(5)
  assert_eq(colors.length(), 5)
  assert_eq(colors[0].r, 31)
  assert_eq(colors[0].g, 119)
  assert_eq(colors[4].b, 189)
  assert_eq(palette(0).length(), 0)
  let gradient = gradient(red, blue, 3)
  assert_eq(gradient[0].r, 255)
  assert_eq(gradient[1].r, 127)
  assert_eq(gradient[2].b, 255)
}

///|
test "color_alpha_and_luminance_clamp_inputs" {
  let transparent = red.with_alpha(2.0)
  assert_eq(transparent.a, 1.0)
  let dark = @color.rgba(0, 0, 0, 1.0).luminance()
  let light = @color.rgba(255, 255, 255, 1.0).luminance()
  assert_eq(dark, 0.0)
  assert_true(light > 0.99)
}
