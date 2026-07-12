///|
pub struct SVGBackend {
  mut content : String
  width : Double
  height : Double
}

///|
pub fn SVGBackend::new(width : Double, height : Double) -> SVGBackend {
  {
    content: "<svg width=\"\{width}\" height=\"\{height}\" xmlns=\"http://www.w3.org/2000/svg\">\n",
    width,
    height,
  }
}

///|
pub fn SVGBackend::add_raw(self : SVGBackend, raw : String) -> Unit {
  self.content = self.content + raw + "\n"
}

///|
pub fn SVGBackend::to_string(self : SVGBackend) -> String {
  self.content + "</svg>"
}

///|
pub fn to_svg_color(color : @color.Color) -> String {
  let r = color.r
  let g = color.g
  let b = color.b
  let a = color.a
  "rgba(\{r},\{g},\{b},\{a})"
}
