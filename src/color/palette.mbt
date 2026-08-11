///|
/// A compact categorical palette chosen for distinct series in small charts.
pub fn palette(count : Int) -> Array[Color] {
  let base = [
    rgba(31, 119, 180, 1.0),
    rgba(255, 127, 14, 1.0),
    rgba(44, 160, 44, 1.0),
    rgba(214, 39, 40, 1.0),
    rgba(148, 103, 189, 1.0),
    rgba(140, 86, 75, 1.0),
    rgba(227, 119, 194, 1.0),
    rgba(127, 127, 127, 1.0),
    rgba(188, 189, 34, 1.0),
    rgba(23, 190, 207, 1.0),
  ]
  let output : Array[Color] = []
  if count <= 0 {
    return output
  }
  for i = 0; i < count; i = i + 1 {
    output.push(base[i % base.length()])
  }
  output
}

///|
pub fn gradient(start : Color, end : Color, count : Int) -> Array[Color] {
  let output : Array[Color] = []
  if count <= 0 {
    return output
  }
  if count == 1 {
    output.push(start)
    return output
  }
  for i = 0; i < count; i = i + 1 {
    let t = i.to_double() / (count - 1).to_double()
    output.push(blend(start, end, t))
  }
  output
}

///|
pub fn Color::with_alpha(self : Color, alpha : Double) -> Color {
  let safe = if alpha < 0.0 { 0.0 } else if alpha > 1.0 { 1.0 } else { alpha }
  { ..self, a: safe }
}

///|
/// Relative luminance approximation in the `[0, 1]` interval.
pub fn Color::luminance(self : Color) -> Double {
  (
    0.2126 * self.r.to_double() +
    0.7152 * self.g.to_double() +
    0.0722 * self.b.to_double()
  ) /
  255.0
}

///|
pub fn Color::contrast_ratio(self : Color, other : Color) -> Double {
  let left = self.luminance() + 0.05
  let right = other.luminance() + 0.05
  if left > right {
    left / right
  } else {
    right / left
  }
}
