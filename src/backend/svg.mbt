///|
pub struct SVGBackend {
  mut content : String
  width : Double
  height : Double
  mut elements : Int
}

///|
pub fn SVGBackend::new(width : Double, height : Double) -> SVGBackend {
  {
    content: "<svg width=\"\{width}\" height=\"\{height}\" xmlns=\"http://www.w3.org/2000/svg\">\n",
    width,
    height,
    elements: 0,
  }
}

///|
pub fn SVGBackend::add_raw(self : SVGBackend, raw : String) -> Unit {
  self.content = self.content + raw + "\n"
  self.elements = self.elements + 1
}

///|
pub fn SVGBackend::element_count(self : SVGBackend) -> Int {
  self.elements
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

///|
fn escape_svg_text(value : String) -> String {
  value
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
  .replace_all(old="'", new="&apos;")
}
