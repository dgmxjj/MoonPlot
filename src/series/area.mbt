///|
/// A filled area series for showing a continuous signal against a baseline.
pub(all) struct AreaSeries {
  points : Array[(Double, Double)]
  baseline : Double
  color : @color.Color
}

///|
pub fn AreaSeries::new(points : Array[(Double, Double)]) -> AreaSeries {
  { points: points.copy(), baseline: 0.0, color: @color.blue }
}

///|
pub fn AreaSeries::set_baseline(
  self : AreaSeries,
  baseline : Double,
) -> AreaSeries {
  { ..self, baseline, }
}

///|
pub fn AreaSeries::set_color(
  self : AreaSeries,
  color : @color.Color,
) -> AreaSeries {
  { ..self, color, }
}

///|
pub fn AreaSeries::point_count(self : AreaSeries) -> Int {
  self.points.length()
}

///|
/// Bounds include the baseline because it is part of the filled geometry.
pub fn AreaSeries::bounds(
  self : AreaSeries,
) -> (Double, Double, Double, Double) {
  if self.points.length() == 0 {
    return (0.0, 0.0, 0.0, 0.0)
  }
  let (first_x, first_y) = self.points[0]
  let mut x_min = first_x
  let mut x_max = first_x
  let mut y_min = if first_y < self.baseline { first_y } else { self.baseline }
  let mut y_max = if first_y > self.baseline { first_y } else { self.baseline }
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
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] AreaSeries::draw(
  self : AreaSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  if self.points.length() == 0 {
    return
  }
  let polygon : Array[(Double, Double)] = []
  let (first_x, _) = self.points[0]
  let (last_x, _) = self.points[self.points.length() - 1]
  polygon.push((scale_x.map(first_x), scale_y.map(self.baseline)))
  for point in self.points {
    polygon.push((scale_x.map(point.0), scale_y.map(point.1)))
  }
  polygon.push((scale_x.map(last_x), scale_y.map(self.baseline)))
  backend.draw_polygon(polygon, self.color, true)
}
