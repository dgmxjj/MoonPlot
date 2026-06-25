pub struct BarSeries {
  data: Array[(String, Double)]
  color: @color.Color
  bar_width: Double
}

pub fn BarSeries::new(data: Array[(String, Double)]) -> BarSeries {
  { data, color: @color.blue, bar_width: 0.8 }
}

pub fn[B : @backend.Backend] BarSeries::draw(self: BarSeries, backend: B, scale_x: @coord.LinearScale, scale_y: @coord.LinearScale) -> Unit {
  let count = self.data.length()
  if count == 0 { return }
  
  let step = (scale_x.range_max - scale_x.range_min) / count.to_double()
  let baseline_y = scale_y.map(0.0)
  
  for i = 0; i < count; i = i + 1 {
    let (_, val) = self.data[i]
    let center_x = scale_x.range_min + step * (i.to_double() + 0.5)
    
    let py = scale_y.map(val)
    let h = baseline_y - py
    let w = step * self.bar_width
    
    let start_x = center_x - w / 2.0
    backend.draw_rect(start_x, py, w, h, self.color, true)
  }
}
