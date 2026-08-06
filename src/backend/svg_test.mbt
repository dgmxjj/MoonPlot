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
