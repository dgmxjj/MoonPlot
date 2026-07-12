///|
pub struct LegendItem {
  name : String
  color : @color.Color
  style : String // "line", "bar", "scatter"
}

///|
pub fn LegendItem::new(
  name : String,
  color : @color.Color,
  style : String,
) -> LegendItem {
  { name, color, style }
}

///|
pub struct ChartBuilder[B] {
  backend : B
  title : String
  padding_left : Double
  padding_right : Double
  padding_top : Double
  padding_bottom : Double
  show_grid : Bool
  legend_items : Array[LegendItem]
}

///|
pub fn[B] ChartBuilder::new(backend : B) -> ChartBuilder[B] {
  {
    backend,
    title: "",
    padding_left: 60.0,
    padding_right: 80.0,
    padding_top: 50.0,
    padding_bottom: 50.0,
    show_grid: true,
    legend_items: [],
  }
}

///|
pub fn[B] ChartBuilder::set_title(
  self : ChartBuilder[B],
  title : String,
) -> ChartBuilder[B] {
  { ..self, title, }
}

///|
pub fn[B] ChartBuilder::set_padding(
  self : ChartBuilder[B],
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
) -> ChartBuilder[B] {
  {
    ..self,
    padding_left: left,
    padding_right: right,
    padding_top: top,
    padding_bottom: bottom,
  }
}

///|
pub fn[B] ChartBuilder::add_legend_item(
  self : ChartBuilder[B],
  name : String,
  color : @color.Color,
  style : String,
) -> ChartBuilder[B] {
  self.legend_items.push(LegendItem::new(name, color, style))
  self
}

///|
pub fn[B : @backend.Backend] ChartBuilder::get_plot_bounds(
  self : ChartBuilder[B],
) -> (Double, Double, Double, Double) {
  let (w, h) = self.backend.get_size()
  let x_min = self.padding_left
  let x_max = w - self.padding_right
  let y_min = self.padding_top + (if self.title != "" { 20.0 } else { 0.0 })
  let y_max = h - self.padding_bottom
  (x_min, y_min, x_max, y_max)
}

///|
pub fn[B : @backend.Backend] ChartBuilder::draw_title(
  self : ChartBuilder[B],
) -> Unit {
  if self.title != "" {
    let (w, _) = self.backend.get_size()
    let font : @backend.Font = {
      family: "sans-serif",
      size: 16.0,
      weight: "bold",
    }
    self.backend.draw_text(
      self.title,
      w / 2.0,
      self.padding_top / 2.0,
      font,
      @color.black,
      @backend.TextAlign::Center,
      @backend.TextBaseline::Middle,
    )
  }
}

///|
pub fn[B : @backend.Backend] ChartBuilder::draw_legend(
  self : ChartBuilder[B],
) -> Unit {
  let count = self.legend_items.length()
  if count == 0 {
    return
  }
  let (w, _) = self.backend.get_size()
  let legend_x = w - self.padding_right + 10.0
  let legend_y_start = self.padding_top + 10.0
  let font = @backend.Font::default()
  for i = 0; i < count; i = i + 1 {
    let item = self.legend_items[i]
    let y = legend_y_start + i.to_double() * 20.0
    let color = item.color
    if item.style == "line" {
      self.backend.draw_line(legend_x, y, legend_x + 15.0, y, color, 2.0)
    } else if item.style == "scatter" {
      self.backend.draw_circle(legend_x + 7.5, y, 4.0, color, true)
    } else if item.style == "bar" {
      self.backend.draw_rect(legend_x, y - 5.0, 15.0, 10.0, color, true)
    }
    self.backend.draw_text(
      item.name,
      legend_x + 20.0,
      y,
      font,
      @color.black,
      @backend.TextAlign::Left,
      @backend.TextBaseline::Middle,
    )
  }
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] ChartBuilder::draw_grid(
  self : ChartBuilder[B],
  scale_x : SX,
  scale_y : SY,
  xticks : Int,
  yticks : Int,
) -> Unit {
  if !self.show_grid {
    return
  }
  let grid_color = @color.rgba(220, 220, 220, 0.8)
  let (x_min, y_min, x_max, y_max) = self.get_plot_bounds()
  let w_len = x_max - x_min
  let h_len = y_max - y_min
  let max_x_ticks = (w_len / 50.0).to_int()
  let final_x_ticks = if xticks > max_x_ticks { max_x_ticks } else { xticks }
  let final_x_ticks = if final_x_ticks < 2 { 2 } else { final_x_ticks }
  let max_y_ticks = (h_len / 40.0).to_int()
  let final_y_ticks = if yticks > max_y_ticks { max_y_ticks } else { yticks }
  let final_y_ticks = if final_y_ticks < 2 { 2 } else { final_y_ticks }
  let x_vals = scale_x.generate_ticks(final_x_ticks)
  let y_vals = scale_y.generate_ticks(final_y_ticks)
  for i = 0; i < x_vals.length(); i = i + 1 {
    let px = scale_x.map(x_vals[i])
    self.backend.draw_line(px, y_min, px, y_max, grid_color, 1.0)
  }
  for i = 0; i < y_vals.length(); i = i + 1 {
    let py = scale_y.map(y_vals[i])
    self.backend.draw_line(x_min, py, x_max, py, grid_color, 1.0)
  }
}

///|
pub fn[B : @backend.Backend, SY : @coord.Scale] ChartBuilder::draw_category_grid(
  self : ChartBuilder[B],
  scale_x : @coord.CategoryScale,
  scale_y : SY,
  yticks : Int,
) -> Unit {
  if !self.show_grid {
    return
  }
  let grid_color = @color.rgba(220, 220, 220, 0.8)
  let (x_min, y_min, x_max, y_max) = self.get_plot_bounds()
  let categories = scale_x.generate_ticks()
  for i = 0; i < categories.length(); i = i + 1 {
    let px = scale_x.map(categories[i])
    self.backend.draw_line(px, y_min, px, y_max, grid_color, 1.0)
  }
  let h_len = y_max - y_min
  let max_y_ticks = (h_len / 40.0).to_int()
  let final_y_ticks = if yticks > max_y_ticks { max_y_ticks } else { yticks }
  let final_y_ticks = if final_y_ticks < 2 { 2 } else { final_y_ticks }
  let y_vals = scale_y.generate_ticks(final_y_ticks)
  for i = 0; i < y_vals.length(); i = i + 1 {
    let py = scale_y.map(y_vals[i])
    self.backend.draw_line(x_min, py, x_max, py, grid_color, 1.0)
  }
}
