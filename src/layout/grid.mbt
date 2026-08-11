///|
/// A backend-independent rectangle used by multi-panel chart layouts.
pub(all) struct Rect {
  x : Double
  y : Double
  width : Double
  height : Double
}

///|
pub fn Rect::right(self : Rect) -> Double {
  self.x + self.width
}

///|
pub fn Rect::bottom(self : Rect) -> Double {
  self.y + self.height
}

///|
pub fn Rect::area(self : Rect) -> Double {
  self.width * self.height
}

///|
pub fn Rect::contains(self : Rect, x : Double, y : Double) -> Bool {
  x >= self.x && x <= self.right() && y >= self.y && y <= self.bottom()
}

///|
pub fn Rect::is_empty(self : Rect) -> Bool {
  self.width <= 0.0 || self.height <= 0.0
}

///|
pub fn Rect::inset(self : Rect, amount : Double) -> Rect {
  let safe = if amount < 0.0 { 0.0 } else { amount }
  let width = self.width - safe * 2.0
  let height = self.height - safe * 2.0
  {
    x: self.x + safe,
    y: self.y + safe,
    width: if width > 0.0 {
      width
    } else {
      0.0
    },
    height: if height > 0.0 {
      height
    } else {
      0.0
    },
  }
}

///|
/// Deterministic row-major panel layout with explicit margins and gaps.
pub(all) struct PanelGrid {
  row_count : Int
  column_count : Int
  width : Double
  height : Double
  gap_x : Double
  gap_y : Double
  margin_left : Double
  margin_right : Double
  margin_top : Double
  margin_bottom : Double
}

///|
pub fn PanelGrid::new(
  rows : Int,
  columns : Int,
  width : Double,
  height : Double,
) -> PanelGrid {
  {
    row_count: if rows > 0 {
      rows
    } else {
      1
    },
    column_count: if columns > 0 {
      columns
    } else {
      1
    },
    width: if width > 0.0 {
      width
    } else {
      0.0
    },
    height: if height > 0.0 {
      height
    } else {
      0.0
    },
    gap_x: 0.0,
    gap_y: 0.0,
    margin_left: 0.0,
    margin_right: 0.0,
    margin_top: 0.0,
    margin_bottom: 0.0,
  }
}

///|
pub fn PanelGrid::set_gap(
  self : PanelGrid,
  horizontal : Double,
  vertical : Double,
) -> PanelGrid {
  {
    ..self,
    gap_x: if horizontal > 0.0 {
      horizontal
    } else {
      0.0
    },
    gap_y: if vertical > 0.0 {
      vertical
    } else {
      0.0
    },
  }
}

///|
pub fn PanelGrid::set_margins(
  self : PanelGrid,
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
) -> PanelGrid {
  {
    ..self,
    margin_left: if left > 0.0 {
      left
    } else {
      0.0
    },
    margin_right: if right > 0.0 {
      right
    } else {
      0.0
    },
    margin_top: if top > 0.0 {
      top
    } else {
      0.0
    },
    margin_bottom: if bottom > 0.0 {
      bottom
    } else {
      0.0
    },
  }
}

///|
pub fn PanelGrid::rows(self : PanelGrid) -> Int {
  self.row_count
}

///|
pub fn PanelGrid::columns(self : PanelGrid) -> Int {
  self.column_count
}

///|
pub fn PanelGrid::panel_count(self : PanelGrid) -> Int {
  self.row_count * self.column_count
}

///|
pub fn PanelGrid::content_bounds(self : PanelGrid) -> Rect {
  let content_width = self.width - self.margin_left - self.margin_right
  let content_height = self.height - self.margin_top - self.margin_bottom
  {
    x: self.margin_left,
    y: self.margin_top,
    width: if content_width > 0.0 {
      content_width
    } else {
      0.0
    },
    height: if content_height > 0.0 {
      content_height
    } else {
      0.0
    },
  }
}

///|
pub fn PanelGrid::panel(self : PanelGrid, index : Int) -> Rect {
  if index < 0 || index >= self.panel_count() {
    return { x: 0.0, y: 0.0, width: 0.0, height: 0.0 }
  }
  let bounds = self.content_bounds()
  let total_gap_x = self.gap_x * (self.column_count - 1).to_double()
  let total_gap_y = self.gap_y * (self.row_count - 1).to_double()
  let panel_width = (bounds.width - total_gap_x) / self.column_count.to_double()
  let panel_height = (bounds.height - total_gap_y) / self.row_count.to_double()
  let column = index % self.column_count
  let row = index / self.column_count
  {
    x: bounds.x + column.to_double() * (panel_width + self.gap_x),
    y: bounds.y + row.to_double() * (panel_height + self.gap_y),
    width: if panel_width > 0.0 {
      panel_width
    } else {
      0.0
    },
    height: if panel_height > 0.0 {
      panel_height
    } else {
      0.0
    },
  }
}

///|
pub fn PanelGrid::row_column(self : PanelGrid, index : Int) -> (Int, Int) {
  if index < 0 || index >= self.panel_count() {
    return (-1, -1)
  }
  (index / self.column_count, index % self.column_count)
}

///|
/// Choose a stable column count for responsive dashboards.
pub fn PanelGrid::columns_for_width(
  width : Double,
  minimum_panel_width : Double,
  gap : Double,
) -> Int {
  if width <= 0.0 || minimum_panel_width <= 0.0 {
    return 1
  }
  let safe_gap = if gap > 0.0 { gap } else { 0.0 }
  let count = ((width + safe_gap) / (minimum_panel_width + safe_gap)).to_int()
  if count > 0 {
    count
  } else {
    1
  }
}
