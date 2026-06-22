pub struct LineSeries {
  points: Array[(Double, Double)]
  color: @color.Color
  width: Double
  smooth: Bool
}

pub fn LineSeries::new(points: Array[(Double, Double)]) -> LineSeries {
  { points, color: @color.blue, width: 2.0, smooth: false }
}

pub fn LineSeries::set_color(self: LineSeries, color: @color.Color) -> LineSeries {
  { ..self, color }
}

pub fn LineSeries::set_width(self: LineSeries, width: Double) -> LineSeries {
  { ..self, width }
}

pub fn[B : @backend.Backend] LineSeries::draw(self: LineSeries, backend: B, scale_x: @coord.LinearScale, scale_y: @coord.LinearScale) -> Unit {
  if self.points.length() < 2 { return }
  
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
