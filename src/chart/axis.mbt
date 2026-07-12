///|
pub struct Axis {
  label : String
  show_ticks : Bool
  tick_count : Int
}

///|
pub fn Axis::new(label : String) -> Axis {
  { label, show_ticks: true, tick_count: 5 }
}

///|
pub fn[B : @backend.Backend, S : @coord.Scale] Axis::draw_x_axis(
  self : Axis,
  backend : B,
  scale_x : S,
  x_min : Double,
  x_max : Double,
  baseline_y : Double,
) -> Unit {
  let axis_color = @color.black
  backend.draw_line(x_min, baseline_y, x_max, baseline_y, axis_color, 2.0)
  if self.show_ticks {
    let font = @backend.Font::default()
    let w_len = x_max - x_min
    let max_ticks = (w_len / 50.0).to_int()
    let final_ticks_cnt = if self.tick_count > max_ticks {
      max_ticks
    } else {
      self.tick_count
    }
    let final_ticks_cnt = if final_ticks_cnt < 2 { 2 } else { final_ticks_cnt }
    let ticks = scale_x.generate_ticks(final_ticks_cnt)
    for i = 0; i < ticks.length(); i = i + 1 {
      let px = scale_x.map(ticks[i])
      backend.draw_line(px, baseline_y, px, baseline_y + 5.0, axis_color, 1.0)
      let label_str = "\{ticks[i]}"
      backend.draw_text(
        label_str,
        px,
        baseline_y + 15.0,
        font,
        axis_color,
        @backend.TextAlign::Center,
        @backend.TextBaseline::Top,
      )
    }
  }
  if self.label != "" {
    let font : @backend.Font = {
      family: "sans-serif",
      size: 12.0,
      weight: "bold",
    }
    backend.draw_text(
      self.label,
      x_min + (x_max - x_min) / 2.0,
      baseline_y + 35.0,
      font,
      axis_color,
      @backend.TextAlign::Center,
      @backend.TextBaseline::Top,
    )
  }
}

///|
pub fn[B : @backend.Backend, S : @coord.Scale] Axis::draw_y_axis(
  self : Axis,
  backend : B,
  scale_y : S,
  y_min : Double,
  y_max : Double,
  baseline_x : Double,
) -> Unit {
  let axis_color = @color.black
  backend.draw_line(baseline_x, y_min, baseline_x, y_max, axis_color, 2.0)
  if self.show_ticks {
    let font = @backend.Font::default()
    let h_len = y_max - y_min
    let max_ticks = (h_len / 40.0).to_int()
    let final_ticks_cnt = if self.tick_count > max_ticks {
      max_ticks
    } else {
      self.tick_count
    }
    let final_ticks_cnt = if final_ticks_cnt < 2 { 2 } else { final_ticks_cnt }
    let ticks = scale_y.generate_ticks(final_ticks_cnt)
    for i = 0; i < ticks.length(); i = i + 1 {
      let py = scale_y.map(ticks[i])
      backend.draw_line(baseline_x, py, baseline_x - 5.0, py, axis_color, 1.0)
      let label_str = "\{ticks[i]}"
      backend.draw_text(
        label_str,
        baseline_x - 10.0,
        py,
        font,
        axis_color,
        @backend.TextAlign::Right,
        @backend.TextBaseline::Middle,
      )
    }
  }
  if self.label != "" {
    let font : @backend.Font = {
      family: "sans-serif",
      size: 12.0,
      weight: "bold",
    }
    backend.draw_text(
      self.label,
      baseline_x - 45.0,
      y_min + (y_max - y_min) / 2.0,
      font,
      axis_color,
      @backend.TextAlign::Center,
      @backend.TextBaseline::Middle,
    )
  }
}

///|
pub fn[B : @backend.Backend] Axis::draw_category_x_axis(
  self : Axis,
  backend : B,
  scale_x : @coord.CategoryScale,
  x_min : Double,
  x_max : Double,
  baseline_y : Double,
) -> Unit {
  let axis_color = @color.black
  backend.draw_line(x_min, baseline_y, x_max, baseline_y, axis_color, 2.0)
  if self.show_ticks {
    let font = @backend.Font::default()
    let categories = scale_x.generate_ticks()
    for i = 0; i < categories.length(); i = i + 1 {
      let cat = categories[i]
      let px = scale_x.map(cat)
      backend.draw_line(px, baseline_y, px, baseline_y + 5.0, axis_color, 1.0)
      backend.draw_text(
        cat,
        px,
        baseline_y + 15.0,
        font,
        axis_color,
        @backend.TextAlign::Center,
        @backend.TextBaseline::Top,
      )
    }
  }
  if self.label != "" {
    let font : @backend.Font = {
      family: "sans-serif",
      size: 12.0,
      weight: "bold",
    }
    backend.draw_text(
      self.label,
      x_min + (x_max - x_min) / 2.0,
      baseline_y + 35.0,
      font,
      axis_color,
      @backend.TextAlign::Center,
      @backend.TextBaseline::Top,
    )
  }
}
