///|
test "svg_backend_escapes_text_content" {
  let backend = SVGBackend::new(100.0, 100.0)
  backend.draw_text(
    "A & B < C > D",
    10.0,
    20.0,
    Font::default(),
    @color.black,
    TextAlign::Left,
    TextBaseline::Top,
  )
  let svg = backend.to_string()
  assert_true(svg.contains("A &amp; B &lt; C &gt; D"))
  assert_true(!svg.contains("A & B < C > D"))
}

///|
test "svg_backend_counts_rendered_elements" {
  let backend = SVGBackend::new(100.0, 100.0)
  backend.draw_circle(10.0, 10.0, 3.0, @color.red, true)
  backend.draw_rect(20.0, 20.0, 4.0, 5.0, @color.blue, false)
  assert_eq(backend.element_count(), 2)
}
