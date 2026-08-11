///|
/// A category-aligned bar series that stacks positive and negative segments
/// around zero independently.
pub(all) struct StackedBarSeries {
  data : Array[(String, Array[Double])]
  colors : Array[@color.Color]
  bar_width : Double
}

///|
pub fn StackedBarSeries::new(
  data : Array[(String, Array[Double])],
) -> StackedBarSeries {
  let series = { data, colors: [], bar_width: 0.8 }
  { ..series, colors: @color.palette(series.segment_count()) }
}

///|
pub fn StackedBarSeries::set_colors(
  self : StackedBarSeries,
  colors : Array[@color.Color],
) -> StackedBarSeries {
  { ..self, colors: colors.copy() }
}

///|
pub fn StackedBarSeries::set_bar_width(
  self : StackedBarSeries,
  width : Double,
) -> StackedBarSeries {
  {
    ..self,
    bar_width: if width < 0.0 {
      0.0
    } else if width > 1.0 {
      1.0
    } else {
      width
    },
  }
}

///|
pub fn StackedBarSeries::category_count(self : StackedBarSeries) -> Int {
  self.data.length()
}

///|
pub fn StackedBarSeries::segment_count(self : StackedBarSeries) -> Int {
  let mut count = 0
  for item in self.data {
    if item.1.length() > count {
      count = item.1.length()
    }
  }
  count
}

///|
/// Return the total stacked extent across all categories.
pub fn StackedBarSeries::bounds(self : StackedBarSeries) -> (Double, Double) {
  let mut low = 0.0
  let mut high = 0.0
  for item in self.data {
    let mut positive = 0.0
    let mut negative = 0.0
    for value in item.1 {
      if value >= 0.0 {
        positive = positive + value
      } else {
        negative = negative + value
      }
    }
    if negative < low {
      low = negative
    }
    if positive > high {
      high = positive
    }
  }
  (low, high)
}

///|
pub fn[B : @backend.Backend, SY : @coord.Scale] StackedBarSeries::draw(
  self : StackedBarSeries,
  backend : B,
  scale_x : @coord.CategoryScale,
  scale_y : SY,
) -> Unit {
  let count = self.data.length()
  if count == 0 {
    return
  }
  let step = (scale_x.range_max - scale_x.range_min) / count.to_double()
  let width = step * self.bar_width
  for item in self.data {
    let category = item.0
    let values = item.1
    let center = scale_x.map(category)
    let mut positive = 0.0
    let mut negative = 0.0
    for i = 0; i < values.length(); i = i + 1 {
      let value = values[i]
      let start = if value >= 0.0 { positive } else { negative }
      let finish = start + value
      if value >= 0.0 {
        positive = finish
      } else {
        negative = finish
      }
      let first_pixel = scale_y.map(start)
      let second_pixel = scale_y.map(finish)
      let rect_y = if first_pixel < second_pixel {
        first_pixel
      } else {
        second_pixel
      }
      let height = if first_pixel > second_pixel {
        first_pixel - second_pixel
      } else {
        second_pixel - first_pixel
      }
      let color = if i < self.colors.length() {
        self.colors[i]
      } else {
        @color.blue
      }
      backend.draw_rect(
        center - width / 2.0,
        rect_y,
        width,
        height,
        color,
        true,
      )
    }
  }
}
