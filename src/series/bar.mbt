///|
pub(all) struct BarSeries {
  data : Array[(String, Double)]
  color : @color.Color
  bar_width : Double
}

///|
pub fn BarSeries::new(data : Array[(String, Double)]) -> BarSeries {
  { data, color: @color.blue, bar_width: 0.8 }
}

///|
pub fn BarSeries::set_color(
  self : BarSeries,
  color : @color.Color,
) -> BarSeries {
  { ..self, color, }
}

///|
/// Keep bars inside their category slot even when a caller supplies an
/// invalid width.
pub fn BarSeries::set_bar_width(self : BarSeries, width : Double) -> BarSeries {
  let safe = if width < 0.0 { 0.0 } else if width > 1.0 { 1.0 } else { width }
  { ..self, bar_width: safe }
}

///|
pub fn BarSeries::values(self : BarSeries) -> Array[Double] {
  let output : Array[Double] = []
  for item in self.data {
    output.push(item.1)
  }
  output
}

///|
/// Return the value range, including zero so the baseline is always visible.
pub fn BarSeries::bounds(self : BarSeries) -> (Double, Double) {
  if self.data.length() == 0 {
    return (0.0, 0.0)
  }
  let mut low = 0.0
  let mut high = 0.0
  for item in self.data {
    let value = item.1
    if value < low {
      low = value
    }
    if value > high {
      high = value
    }
  }
  (low, high)
}

///|
pub fn[B : @backend.Backend, SY : @coord.Scale] BarSeries::draw(
  self : BarSeries,
  backend : B,
  scale_x : @coord.CategoryScale,
  scale_y : SY,
) -> Unit {
  let count = self.data.length()
  if count == 0 {
    return
  }
  let baseline_y = scale_y.map(0.0)
  let step = (scale_x.range_max - scale_x.range_min) / count.to_double()
  let w = step * self.bar_width
  for i = 0; i < count; i = i + 1 {
    let (cat, val) = self.data[i]
    let center_x = scale_x.map(cat)
    let py = scale_y.map(val)
    let rect_y = if py < baseline_y { py } else { baseline_y }
    let h = if baseline_y > py { baseline_y - py } else { py - baseline_y }
    let start_x = center_x - w / 2.0
    backend.draw_rect(start_x, rect_y, w, h, self.color, true)
  }
}
