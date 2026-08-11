///|
pub(all) enum LegendFlow {
  Vertical
  Horizontal
}

///|
pub(all) struct LegendEntry {
  label : String
  width : Double
}

///|
/// A layout-only legend flow engine. Rendering remains owned by the backend.
pub(all) struct LegendLayout {
  origin_x : Double
  origin_y : Double
  max_width : Double
  line_height : Double
  gap : Double
  flow : LegendFlow
  entries : Array[LegendEntry]
}

///|
pub fn LegendLayout::new(
  x : Double,
  y : Double,
  max_width : Double,
) -> LegendLayout {
  {
    origin_x: x,
    origin_y: y,
    max_width: if max_width > 0.0 {
      max_width
    } else {
      0.0
    },
    line_height: 16.0,
    gap: 4.0,
    flow: LegendFlow::Vertical,
    entries: [],
  }
}

///|
pub fn LegendLayout::set_flow(
  self : LegendLayout,
  flow : LegendFlow,
) -> LegendLayout {
  { ..self, flow, }
}

///|
pub fn LegendLayout::set_line_height(
  self : LegendLayout,
  height : Double,
) -> LegendLayout {
  { ..self, line_height: if height > 0.0 { height } else { 16.0 } }
}

///|
pub fn LegendLayout::set_gap(self : LegendLayout, gap : Double) -> LegendLayout {
  { ..self, gap: if gap > 0.0 { gap } else { 0.0 } }
}

///|
pub fn LegendLayout::add(
  self : LegendLayout,
  label : String,
  width : Double,
) -> LegendLayout {
  self.entries.push({ label, width: if width > 0.0 { width } else { 0.0 } })
  self
}

///|
pub fn LegendLayout::entry_count(self : LegendLayout) -> Int {
  self.entries.length()
}

///|
pub fn LegendLayout::item_position(
  self : LegendLayout,
  index : Int,
) -> (Double, Double) {
  if index < 0 || index >= self.entries.length() {
    return (self.origin_x, self.origin_y)
  }
  match self.flow {
    LegendFlow::Vertical =>
      (
        self.origin_x,
        self.origin_y + index.to_double() * (self.line_height + self.gap),
      )
    LegendFlow::Horizontal => self.horizontal_position(index)
  }
}

///|
fn LegendLayout::horizontal_position(
  self : LegendLayout,
  index : Int,
) -> (Double, Double) {
  let mut x = self.origin_x
  let mut row = 0
  for i = 0; i < index; i = i + 1 {
    let width = self.entries[i].width
    if self.max_width > 0.0 &&
      x > self.origin_x &&
      x + self.gap + width > self.origin_x + self.max_width {
      x = self.origin_x
      row = row + 1
    } else {
      if x > self.origin_x {
        x = x + self.gap
      }
      x = x + width
    }
  }
  let current_width = self.entries[index].width
  if self.max_width > 0.0 &&
    x > self.origin_x &&
    x + self.gap + current_width > self.origin_x + self.max_width {
    (
      self.origin_x,
      self.origin_y + (row + 1).to_double() * (self.line_height + self.gap),
    )
  } else {
    (
      if x > self.origin_x {
        x + self.gap
      } else {
        x
      },
      self.origin_y + row.to_double() * (self.line_height + self.gap),
    )
  }
}

///|
pub fn LegendLayout::rows(self : LegendLayout) -> Int {
  if self.entries.length() == 0 {
    return 0
  }
  match self.flow {
    LegendFlow::Vertical => self.entries.length()
    LegendFlow::Horizontal => {
      let mut max_row = 0
      for i = 0; i < self.entries.length(); i = i + 1 {
        let (_, y) = self.item_position(i)
        let row = ((y - self.origin_y) / (self.line_height + self.gap)).to_int()
        if row > max_row {
          max_row = row
        }
      }
      max_row + 1
    }
  }
}

///|
pub fn LegendLayout::content_size(self : LegendLayout) -> (Double, Double) {
  if self.entries.length() == 0 {
    return (0.0, 0.0)
  }
  let mut right = self.origin_x
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (x, _) = self.item_position(i)
    let item_right = x + self.entries[i].width
    if item_right > right {
      right = item_right
    }
  }
  let row_count = self.rows()
  let height = row_count.to_double() * self.line_height +
    (row_count - 1).to_double() * self.gap
  (right - self.origin_x, height)
}
