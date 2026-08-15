///|
/// A compact Tukey-style box plot with lower/upper whiskers.
pub(all) struct BoxPlotSeries {
  position : Double
  minimum_value : Double
  lower_quartile_value : Double
  median_value : Double
  upper_quartile_value : Double
  maximum_value : Double
  box_width : Double
  color : @color.Color
}

///|
pub fn BoxPlotSeries::new(
  position : Double,
  values : Array[Double],
) -> BoxPlotSeries {
  let sorted = values.copy()
  sorted.sort()
  if sorted.length() == 0 {
    return {
      position,
      minimum_value: 0.0,
      lower_quartile_value: 0.0,
      median_value: 0.0,
      upper_quartile_value: 0.0,
      maximum_value: 0.0,
      box_width: 0.6,
      color: @color.red,
    }
  }
  {
    position,
    minimum_value: sorted[0],
    lower_quartile_value: box_quantile(sorted, 0.25),
    median_value: box_quantile(sorted, 0.5),
    upper_quartile_value: box_quantile(sorted, 0.75),
    maximum_value: sorted[sorted.length() - 1],
    box_width: 0.6,
    color: @color.red,
  }
}

///|
pub fn BoxPlotSeries::set_width(
  self : BoxPlotSeries,
  width : Double,
) -> BoxPlotSeries {
  { ..self, box_width: if width > 0.0 { width } else { 0.0 } }
}

///|
pub fn BoxPlotSeries::set_color(
  self : BoxPlotSeries,
  color : @color.Color,
) -> BoxPlotSeries {
  { ..self, color, }
}

///|
pub fn BoxPlotSeries::width(self : BoxPlotSeries) -> Double {
  self.box_width
}

///|
pub fn BoxPlotSeries::minimum(self : BoxPlotSeries) -> Double {
  self.minimum_value
}

///|
pub fn BoxPlotSeries::lower_quartile(self : BoxPlotSeries) -> Double {
  self.lower_quartile_value
}

///|
pub fn BoxPlotSeries::median(self : BoxPlotSeries) -> Double {
  self.median_value
}

///|
pub fn BoxPlotSeries::upper_quartile(self : BoxPlotSeries) -> Double {
  self.upper_quartile_value
}

///|
pub fn BoxPlotSeries::maximum(self : BoxPlotSeries) -> Double {
  self.maximum_value
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] BoxPlotSeries::draw(
  self : BoxPlotSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  if self.box_width == 0.0 || self.minimum_value == self.maximum_value {
    return
  }
  let center = scale_x.map(self.position)
  let left = scale_x.map(self.position - self.box_width / 2.0)
  let right = scale_x.map(self.position + self.box_width / 2.0)
  let box_left = if left < right { left } else { right }
  let box_width = if left < right { right - left } else { left - right }
  let q1 = scale_y.map(self.lower_quartile_value)
  let q3 = scale_y.map(self.upper_quartile_value)
  let box_top = if q1 < q3 { q1 } else { q3 }
  let box_height = if q1 < q3 { q3 - q1 } else { q1 - q3 }
  backend.draw_rect(box_left, box_top, box_width, box_height, self.color, true)
  backend.draw_line(
    center,
    scale_y.map(self.minimum_value),
    center,
    scale_y.map(self.lower_quartile_value),
    self.color,
    1.0,
  )
  backend.draw_line(
    center,
    scale_y.map(self.upper_quartile_value),
    center,
    scale_y.map(self.maximum_value),
    self.color,
    1.0,
  )
  backend.draw_line(
    box_left,
    scale_y.map(self.median_value),
    box_left + box_width,
    scale_y.map(self.median_value),
    self.color,
    2.0,
  )
  backend.draw_line(
    box_left,
    scale_y.map(self.minimum_value),
    box_left + box_width,
    scale_y.map(self.minimum_value),
    self.color,
    1.0,
  )
  backend.draw_line(
    box_left,
    scale_y.map(self.maximum_value),
    box_left + box_width,
    scale_y.map(self.maximum_value),
    self.color,
    1.0,
  )
}

///|
fn box_quantile(sorted : Array[Double], probability : Double) -> Double {
  let position = probability * (sorted.length() - 1).to_double()
  let lower = position.to_int()
  let upper = if position == lower.to_double() { lower } else { lower + 1 }
  if lower == upper {
    sorted[lower]
  } else {
    let weight = position - lower.to_double()
    sorted[lower] * (1.0 - weight) + sorted[upper] * weight
  }
}
