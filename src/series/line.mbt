///|
pub(all) struct LineSeries {
  points : Array[(Double, Double)]
  color : @color.Color
  width : Double
  smooth : Bool
}

///|
pub fn LineSeries::new(points : Array[(Double, Double)]) -> LineSeries {
  { points, color: @color.blue, width: 2.0, smooth: false }
}

///|
pub fn LineSeries::set_color(
  self : LineSeries,
  color : @color.Color,
) -> LineSeries {
  { ..self, color, }
}

///|
pub fn LineSeries::set_width(self : LineSeries, width : Double) -> LineSeries {
  { ..self, width: if width > 0.0 { width } else { 0.0 } }
}

///|
pub fn LineSeries::set_smooth(self : LineSeries, smooth : Bool) -> LineSeries {
  { ..self, smooth, }
}

///|
pub fn LineSeries::is_smooth(self : LineSeries) -> Bool {
  self.smooth
}

///|
/// Return `(x_min, y_min, x_max, y_max)` for autoscaling and annotations.
pub fn LineSeries::bounds(
  self : LineSeries,
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
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] LineSeries::draw(
  self : LineSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  if self.points.length() < 2 {
    return
  }
  let mut prev_x = scale_x.map(self.points[0].0)
  let mut prev_y = scale_y.map(self.points[0].1)
  for i = 1; i < self.points.length(); i = i + 1 {
    let px = scale_x.map(self.points[i].0)
    let py = scale_y.map(self.points[i].1)
    backend.draw_line(prev_x, prev_y, px, py, self.color, self.width)
    prev_x = px
    prev_y = py
  }
}
