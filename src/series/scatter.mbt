///|
pub(all) enum PointStyle {
  Circle
  Square
  Cross
}

///|
pub(all) struct ScatterSeries {
  points : Array[(Double, Double)]
  radius : Double
  color : @color.Color
  style : PointStyle
}

///|
pub fn ScatterSeries::new(points : Array[(Double, Double)]) -> ScatterSeries {
  { points, radius: 3.0, color: @color.red, style: PointStyle::Circle }
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] ScatterSeries::draw(
  self : ScatterSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  for i = 0; i < self.points.length(); i = i + 1 {
    let px = scale_x.map(self.points[i].0)
    let py = scale_y.map(self.points[i].1)
    match self.style {
      PointStyle::Circle =>
        backend.draw_circle(px, py, self.radius, self.color, true)
      PointStyle::Square => {
        let r = self.radius
        backend.draw_rect(px - r, py - r, r * 2.0, r * 2.0, self.color, true)
      }
      PointStyle::Cross => {
        let r = self.radius
        backend.draw_line(px - r, py - r, px + r, py + r, self.color, 2.0)
        backend.draw_line(px - r, py + r, px + r, py - r, self.color, 2.0)
      }
    }
  }
}
