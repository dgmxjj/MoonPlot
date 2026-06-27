pub struct Axis {
  label: String
  show_ticks: Bool
  tick_count: Int
}

pub fn Axis::new(label: String) -> Axis {
  { label, show_ticks: true, tick_count: 5 }
}

pub fn[B : @backend.Backend] Axis::draw_x_axis(self: Axis, backend: B, scale_x: @coord.LinearScale, baseline_y: Double) -> Unit {
  let axis_color = @color.black
  
  // Draw main axis line
  backend.draw_line(scale_x.range_min, baseline_y, scale_x.range_max, baseline_y, axis_color, 2.0)
  
  // Draw ticks
  if self.show_ticks {
    let font = @backend.Font::default()
    let ticks = scale_x.generate_ticks(self.tick_count)
    for i = 0; i < ticks.length(); i = i + 1 {
      let px = scale_x.map(ticks[i])
      backend.draw_line(px, baseline_y, px, baseline_y + 5.0, axis_color, 1.0)
      
      // simplistic float to string for now
      let label_str = "\{ticks[i]}" 
      backend.draw_text(label_str, px, baseline_y + 15.0, font, axis_color, @backend.TextAlign::Center, @backend.TextBaseline::Top)
    }
  }
}
