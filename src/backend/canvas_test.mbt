///|
test "canvas_backend_emits_commands_and_escapes_text" {
  let backend = CanvasBackend::new(320.0, 200.0)
  backend.draw_line(0.0, 1.0, 10.0, 20.0, @color.red, 2.0)
  backend.draw_text(
    "O'Reilly MoonBit",
    12.0,
    24.0,
    Font::default(),
    @color.black,
    TextAlign::Left,
    TextBaseline::Top,
  )
  let js = backend.to_js_code("ctx")
  assert_true(js.contains("ctx.strokeStyle = 'rgba(255,0,0,1)';"))
  assert_true(js.contains("fillText('O\\'Reilly MoonBit'"))
}

///|
test "canvas_backend_ignores_empty_polygon" {
  let backend = CanvasBackend::new(320.0, 200.0)
  backend.draw_polygon([], @color.blue, true)
  assert_eq(backend.to_js_code("ctx"), "")
}

///|
test "canvas_backend_exposes_reproducible_command_lifecycle" {
  let backend = CanvasBackend::new(320.0, 200.0)
  backend.draw_rect(1.0, 2.0, 10.0, 20.0, @color.blue, true)
  assert_eq(backend.command_count(), 2)
  assert_true(backend.command_at(1).contains("fillRect"))
  backend.clear()
  assert_eq(backend.command_count(), 0)
}
