pub struct Font {
  family: String
  size: Double
  weight: String
}

pub fn Font::default() -> Font {
  { family: "sans-serif", size: 12.0, weight: "normal" }
}

pub(all) enum TextAlign {
  Left
  Center
  Right
}

pub(all) enum TextBaseline {
  Top
  Middle
  Bottom
}

pub trait Backend {
  get_size(self : Self) -> (Double, Double)
  draw_line(self : Self, x1: Double, y1: Double, x2: Double, y2: Double, color: @color.Color, width: Double) -> Unit
  draw_rect(self : Self, x: Double, y: Double, w: Double, h: Double, color: @color.Color, fill: Bool) -> Unit
  draw_circle(self : Self, x: Double, y: Double, radius: Double, color: @color.Color, fill: Bool) -> Unit
  draw_polygon(self : Self, points: Array[(Double, Double)], color: @color.Color, fill: Bool) -> Unit
  draw_text(self : Self, text: String, x: Double, y: Double, font: Font, color: @color.Color, align: TextAlign, baseline: TextBaseline) -> Unit
}
