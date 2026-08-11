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
pub fn ScatterSeries::set_color(
  self : ScatterSeries,
  color : @color.Color,
) -> ScatterSeries {
  { ..self, color, }
}

///|
pub fn ScatterSeries::set_radius(
  self : ScatterSeries,
  radius : Double,
) -> ScatterSeries {
  { ..self, radius: if radius > 0.0 { radius } else { 0.0 } }
}

///|
pub fn ScatterSeries::set_style(
  self : ScatterSeries,
  style : PointStyle,
) -> ScatterSeries {
  { ..self, style, }
}

///|
pub fn ScatterSeries::point_count(self : ScatterSeries) -> Int {
  self.points.length()
}

///|
pub fn ScatterSeries::bounds(
  self : ScatterSeries,
) -> (Double, Double, Double, Double) {
  if self.points.length() == 0 {
    return (0.0, 0.0, 0.0, 0.0)
  }
  let (first_x, first_y) = self.points[0]
  let mut x_min = first_x
  let mut x_max = first_x
  let mut y_min = first_y
  let mut y_max = first_y
  for i = 1; i < self.points.length(); i = i + 1 {
    let (x, y) = self.points[i]
    if x < x_min {
      x_min = x
    }
    if x > x_max {
      x_max = x
    }
    if y < y_min {
      y_min = y
    }
    if y > y_max {
      y_max = y
    }
  }
  (x_min, y_min, x_max, y_max)
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
