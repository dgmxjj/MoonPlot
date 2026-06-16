pub struct Color {
  r: Int
  g: Int
  b: Int
  a: Double
}

pub fn rgba(r: Int, g: Int, b: Int, a: Double) -> Color {
  { r, g, b, a }
}

pub let black : Color = rgba(0, 0, 0, 1.0)
pub let red : Color = rgba(255, 0, 0, 1.0)
pub let blue : Color = rgba(0, 0, 255, 1.0)
pub let light_gray : Color = rgba(211, 211, 211, 1.0)

pub fn blend(c1: Color, c2: Color, t: Double) -> Color {
  let r = (c1.r.to_double() * (1.0 - t) + c2.r.to_double() * t).to_int()
  let g = (c1.g.to_double() * (1.0 - t) + c2.g.to_double() * t).to_int()
  let b = (c1.b.to_double() * (1.0 - t) + c2.b.to_double() * t).to_int()
  let a = c1.a * (1.0 - t) + c2.a * t
  { r, g, b, a }
}
