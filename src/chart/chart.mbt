pub struct ChartBuilder[B] {
  backend: B
  title: String
  margin: Double
  show_grid: Bool
}

pub fn[B] ChartBuilder::new(backend: B) -> ChartBuilder[B] {
  { backend, title: "", margin: 40.0, show_grid: true }
}

pub fn[B] ChartBuilder::set_title(self: ChartBuilder[B], title: String) -> ChartBuilder[B] {
  { ..self, title }
}

pub fn[B : @backend.Backend] ChartBuilder::draw_title(self: ChartBuilder[B]) -> Unit {
  if self.title != "" {
    let (w, _) = self.backend.get_size()
    let font = @backend.Font::default()
    self.backend.draw_text(self.title, w / 2.0, self.margin / 2.0, font, @color.black, @backend.TextAlign::Center, @backend.TextBaseline::Middle)
  }
}

pub fn[B : @backend.Backend] ChartBuilder::draw_grid(self: ChartBuilder[B], scale_x: @coord.LinearScale, scale_y: @coord.LinearScale, xticks: Int, yticks: Int) -> Unit {
  if !self.show_grid { return }
  
  let grid_color = @color.light_gray
  let x_vals = scale_x.generate_ticks(xticks)
  let y_vals = scale_y.generate_ticks(yticks)
  
  for i = 0; i < x_vals.length(); i = i + 1 {
    let px = scale_x.map(x_vals[i])
    self.backend.draw_line(px, scale_y.range_min, px, scale_y.range_max, grid_color, 1.0)
  }
  
  for i = 0; i < y_vals.length(); i = i + 1 {
    let py = scale_y.map(y_vals[i])
    self.backend.draw_line(scale_x.range_min, py, scale_x.range_max, py, grid_color, 1.0)
  }
}
