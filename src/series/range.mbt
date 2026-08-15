///|
/// A lower/upper band useful for confidence intervals and monitored limits.
pub(all) struct RangeSeries {
  points : Array[(Double, Double, Double)]
  opacity_value : Double
  fill_color : @color.Color
  line_color : @color.Color
}

///|
pub fn RangeSeries::new(
  points : Array[(Double, Double, Double)],
) -> RangeSeries {
  let normalized : Array[(Double, Double, Double)] = []
  for point in points {
    let low = if point.1 < point.2 { point.1 } else { point.2 }
    let high = if point.1 < point.2 { point.2 } else { point.1 }
    normalized.push((point.0, low, high))
  }
  {
    points: normalized,
    opacity_value: 0.35,
    fill_color: @color.blue,
    line_color: @color.blue,
  }
}

///|
pub fn RangeSeries::set_opacity(
  self : RangeSeries,
  opacity : Double,
) -> RangeSeries {
  let safe = if opacity < 0.0 {
    0.0
  } else if opacity > 1.0 {
    1.0
  } else {
    opacity
  }
  { ..self, opacity_value: safe }
}

///|
pub fn RangeSeries::set_colors(
  self : RangeSeries,
  fill_color : @color.Color,
  line_color : @color.Color,
) -> RangeSeries {
  { ..self, fill_color, line_color }
}

///|
pub fn RangeSeries::opacity(self : RangeSeries) -> Double {
  self.opacity_value
}

///|
pub fn RangeSeries::values(
  self : RangeSeries,
) -> Array[(Double, Double, Double)] {
  self.points.copy()
}

///|
pub fn RangeSeries::bounds(
  self : RangeSeries,
) -> (Double, Double, Double, Double) {
  if self.points.length() == 0 {
    return (0.0, 0.0, 0.0, 0.0)
  }
  let (first_x, first_low, first_high) = self.points[0]
  let mut x_min = first_x
  let mut x_max = first_x
  let mut y_min = first_low
  let mut y_max = first_high
  for i = 1; i < self.points.length(); i = i + 1 {
    let (x, low, high) = self.points[i]
    if x < x_min {
      x_min = x
    }
    if x > x_max {
      x_max = x
    }
    if low < y_min {
      y_min = low
    }
    if high > y_max {
      y_max = high
    }
  }
  (x_min, y_min, x_max, y_max)
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] RangeSeries::draw(
  self : RangeSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  if self.points.length() == 0 {
    return
  }
  let polygon : Array[(Double, Double)] = []
  for point in self.points {
    polygon.push((scale_x.map(point.0), scale_y.map(point.2)))
  }
  let mut i = self.points.length() - 1
  while i >= 0 {
    let point = self.points[i]
    polygon.push((scale_x.map(point.0), scale_y.map(point.1)))
    i = i - 1
  }
  backend.draw_polygon(
    polygon,
    self.fill_color.with_alpha(self.opacity_value),
    true,
  )
  for i = 1; i < self.points.length(); i = i + 1 {
    let previous = self.points[i - 1]
    let current = self.points[i]
    backend.draw_line(
      scale_x.map(previous.0),
      scale_y.map(previous.1),
      scale_x.map(current.0),
      scale_y.map(current.1),
      self.line_color,
      1.5,
    )
    backend.draw_line(
      scale_x.map(previous.0),
      scale_y.map(previous.2),
      scale_x.map(current.0),
      scale_y.map(current.2),
      self.line_color,
      1.5,
    )
  }
}
