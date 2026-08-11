///|
pub struct CanvasBackend {
  commands : Array[String]
  width : Double
  height : Double
}

///|
pub fn CanvasBackend::new(width : Double, height : Double) -> CanvasBackend {
  { commands: [], width, height }
}

///|
pub fn CanvasBackend::to_js_code(
  self : CanvasBackend,
  ctx_name : String,
) -> String {
  let mut js = ""
  for i = 0; i < self.commands.length(); i = i + 1 {
    js = js + ctx_name + "." + self.commands[i] + "\n"
  }
  js
}

///|
pub fn CanvasBackend::command_count(self : CanvasBackend) -> Int {
  self.commands.length()
}

///|
/// Return an empty command for an invalid index so inspection tools can stay
/// total while rendering is in progress.
pub fn CanvasBackend::command_at(self : CanvasBackend, index : Int) -> String {
  if index < 0 || index >= self.commands.length() {
    return ""
  }
  self.commands[index]
}

///|
pub fn CanvasBackend::clear(self : CanvasBackend) -> Unit {
  self.commands.clear()
}

///|
pub fn to_canvas_color(color : @color.Color) -> String {
  let r = color.r
  let g = color.g
  let b = color.b
  let a = color.a
  "rgba(\{r},\{g},\{b},\{a})"
}

///|
fn escape_js_string(value : String) -> String {
  value
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="'", new="\\'")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
}

///|
pub impl Backend for CanvasBackend with fn get_size(self) {
  (self.width, self.height)
}

///|
pub impl Backend for CanvasBackend with fn draw_line(
  self,
  x1,
  y1,
  x2,
  y2,
  color,
  width,
) {
  let c = to_canvas_color(color)
  self.commands.push("strokeStyle = '\{c}';")
  self.commands.push("lineWidth = \{width};")
  self.commands.push("beginPath();")
  self.commands.push("moveTo(\{x1}, \{y1});")
  self.commands.push("lineTo(\{x2}, \{y2});")
  self.commands.push("stroke();")
}

///|
pub impl Backend for CanvasBackend with fn draw_rect(
  self,
  x,
  y,
  w,
  h,
  color,
  fill,
) {
  let c = to_canvas_color(color)
  if fill {
    self.commands.push("fillStyle = '\{c}';")
    self.commands.push("fillRect(\{x}, \{y}, \{w}, \{h});")
  } else {
    self.commands.push("strokeStyle = '\{c}';")
    self.commands.push("lineWidth = 1.0;")
    self.commands.push("strokeRect(\{x}, \{y}, \{w}, \{h});")
  }
}

///|
pub impl Backend for CanvasBackend with fn draw_circle(
  self,
  x,
  y,
  radius,
  color,
  fill,
) {
  let c = to_canvas_color(color)
  self.commands.push("beginPath();")
  self.commands.push("arc(\{x}, \{y}, \{radius}, 0, 2 * Math.PI);")
  if fill {
    self.commands.push("fillStyle = '\{c}';")
    self.commands.push("fill();")
  } else {
    self.commands.push("strokeStyle = '\{c}';")
    self.commands.push("lineWidth = 1.0;")
    self.commands.push("stroke();")
  }
}

///|
pub impl Backend for CanvasBackend with fn draw_polygon(
  self,
  points,
  color,
  fill,
) {
  if points.length() == 0 {
    return
  }
  let c = to_canvas_color(color)
  self.commands.push("beginPath();")
  let (x0, y0) = points[0]
  self.commands.push("moveTo(\{x0}, \{y0});")
  for i = 1; i < points.length(); i = i + 1 {
    let (x, y) = points[i]
    self.commands.push("lineTo(\{x}, \{y});")
  }
  self.commands.push("closePath();")
  if fill {
    self.commands.push("fillStyle = '\{c}';")
    self.commands.push("fill();")
  } else {
    self.commands.push("strokeStyle = '\{c}';")
    self.commands.push("lineWidth = 1.0;")
    self.commands.push("stroke();")
  }
}

///|
pub impl Backend for CanvasBackend with fn draw_text(
  self,
  text,
  x,
  y,
  font,
  color,
  align,
  baseline,
) {
  let c = to_canvas_color(color)
  let escaped_text = escape_js_string(text)
  let anchor = match align {
    TextAlign::Left => "left"
    TextAlign::Center => "center"
    TextAlign::Right => "right"
  }
  let base = match baseline {
    TextBaseline::Top => "top"
    TextBaseline::Middle => "middle"
    TextBaseline::Bottom => "bottom"
  }
  self.commands.push("font = '\{font.weight} \{font.size}px \{font.family}';")
  self.commands.push("fillStyle = '\{c}';")
  self.commands.push("textAlign = '\{anchor}';")
  self.commands.push("textBaseline = '\{base}';")
  self.commands.push("fillText('\{escaped_text}', \{x}, \{y});")
}
