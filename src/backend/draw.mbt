///|
pub impl Backend for SVGBackend with fn get_size(self) {
  (self.width, self.height)
}

///|
pub impl Backend for SVGBackend with fn draw_line(
  self,
  x1,
  y1,
  x2,
  y2,
  color,
  width,
) {
  let c = to_svg_color(color)
  let svg = "<line x1=\"\{x1}\" y1=\"\{y1}\" x2=\"\{x2}\" y2=\"\{y2}\" stroke=\"\{c}\" stroke-width=\"\{width}\" />"
  self.add_raw(svg)
}

///|
pub impl Backend for SVGBackend with fn draw_rect(self, x, y, w, h, color, fill) {
  let c = to_svg_color(color)
  let attr = if fill {
    "fill=\"\{c}\""
  } else {
    "fill=\"none\" stroke=\"\{c}\" stroke-width=\"1\""
  }
  let svg = "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{w}\" height=\"\{h}\" \{attr} />"
  self.add_raw(svg)
}

///|
pub impl Backend for SVGBackend with fn draw_circle(
  self,
  x,
  y,
  radius,
  color,
  fill,
) {
  let c = to_svg_color(color)
  let attr = if fill {
    "fill=\"\{c}\""
  } else {
    "fill=\"none\" stroke=\"\{c}\" stroke-width=\"1\""
  }
  let svg = "<circle cx=\"\{x}\" cy=\"\{y}\" r=\"\{radius}\" \{attr} />"
  self.add_raw(svg)
}

///|
pub impl Backend for SVGBackend with fn draw_polygon(self, points, color, fill) {
  let c = to_svg_color(color)
  let attr = if fill {
    "fill=\"\{c}\""
  } else {
    "fill=\"none\" stroke=\"\{c}\" stroke-width=\"1\""
  }
  let mut pts_str = ""
  for i = 0; i < points.length(); i = i + 1 {
    let (x, y) = points[i]
    pts_str = pts_str + "\{x},\{y} "
  }
  let svg = "<polygon points=\"\{pts_str}\" \{attr} />"
  self.add_raw(svg)
}

///|
pub impl Backend for SVGBackend with fn draw_text(
  self,
  text,
  x,
  y,
  font,
  color,
  align,
  baseline,
) {
  let c = to_svg_color(color)
  let anchor = match align {
    TextAlign::Left => "start"
    TextAlign::Center => "middle"
    TextAlign::Right => "end"
  }
  let dom_baseline = match baseline {
    TextBaseline::Top => "hanging"
    TextBaseline::Middle => "middle"
    TextBaseline::Bottom => "alphabetic"
  }
  let style = "font-family: \{font.family}; font-size: \{font.size}px; font-weight: \{font.weight}; fill: \{c};"
  let svg = "<text x=\"\{x}\" y=\"\{y}\" text-anchor=\"\{anchor}\" dominant-baseline=\"\{dom_baseline}\" style=\"\{style}\">\{text}</text>"
  self.add_raw(svg)
}
