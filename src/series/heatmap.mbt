///|
/// A rectangular matrix rendered as one colored cell per value.
pub(all) struct HeatmapSeries {
  values : Array[Array[Double]]
  low : Double
  high : Double
  start_color : @color.Color
  end_color : @color.Color
}

///|
pub fn HeatmapSeries::new(values : Array[Array[Double]]) -> HeatmapSeries {
  let copied : Array[Array[Double]] = []
  let mut has_value = false
  let mut low = 0.0
  let mut high = 0.0
  for row in values {
    copied.push(row.copy())
    for value in row {
      if !has_value {
        low = value
        high = value
        has_value = true
      } else {
        if value < low {
          low = value
        }
        if value > high {
          high = value
        }
      }
    }
  }
  if !has_value {
    low = 0.0
    high = 1.0
  }
  {
    values: copied,
    low,
    high,
    start_color: @color.light_gray,
    end_color: @color.blue,
  }
}

///|
pub fn HeatmapSeries::set_domain(
  self : HeatmapSeries,
  low : Double,
  high : Double,
) -> HeatmapSeries {
  if low <= high {
    { ..self, low, high }
  } else {
    { ..self, low: high, high: low }
  }
}

///|
pub fn HeatmapSeries::set_colors(
  self : HeatmapSeries,
  start_color : @color.Color,
  end_color : @color.Color,
) -> HeatmapSeries {
  { ..self, start_color, end_color }
}

///|
pub fn HeatmapSeries::rows(self : HeatmapSeries) -> Int {
  self.values.length()
}

///|
pub fn HeatmapSeries::columns(self : HeatmapSeries) -> Int {
  let mut result = 0
  for row in self.values {
    if row.length() > result {
      result = row.length()
    }
  }
  result
}

///|
pub fn HeatmapSeries::cell(
  self : HeatmapSeries,
  row : Int,
  column : Int,
) -> Double {
  if row < 0 || row >= self.values.length() {
    return 0.0
  }
  if column < 0 || column >= self.values[row].length() {
    return 0.0
  }
  self.values[row][column]
}

///|
fn HeatmapSeries::color_for(
  self : HeatmapSeries,
  value : Double,
) -> @color.Color {
  let span = self.high - self.low
  let ratio = if span == 0.0 { 0.5 } else { (value - self.low) / span }
  @color.blend(self.start_color, self.end_color, ratio)
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] HeatmapSeries::draw(
  self : HeatmapSeries,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  let column_count = self.columns()
  if self.rows() == 0 || column_count == 0 {
    return
  }
  for row_index = 0; row_index < self.rows(); row_index = row_index + 1 {
    let row = self.values[row_index]
    for column_index = 0
        column_index < row.length()
        column_index = column_index + 1 {
      let x0 = scale_x.map(column_index.to_double())
      let x1 = scale_x.map((column_index + 1).to_double())
      let y0 = scale_y.map(row_index.to_double())
      let y1 = scale_y.map((row_index + 1).to_double())
      let left = if x0 < x1 { x0 } else { x1 }
      let top = if y0 < y1 { y0 } else { y1 }
      let width = if x0 < x1 { x1 - x0 } else { x0 - x1 }
      let height = if y0 < y1 { y1 - y0 } else { y0 - y1 }
      backend.draw_rect(
        left,
        top,
        width,
        height,
        self.color_for(row[column_index]),
        true,
      )
    }
  }
}
