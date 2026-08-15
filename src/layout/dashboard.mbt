///|
/// A named collection of non-overlapping panels backed by `PanelGrid`.
pub(all) struct DashboardPanel {
  title : String
  bounds : Rect
  index : Int
}

///|
pub(all) struct Dashboard {
  grid : PanelGrid
  panel_limit : Int
  titles : Array[String]
}

///|
pub fn Dashboard::new(
  width : Double,
  height : Double,
  rows : Int,
  columns : Int,
) -> Dashboard {
  let limit = if rows > 0 && columns > 0 { rows * columns } else { 0 }
  {
    grid: PanelGrid::new(
      rows,
      columns,
      if width > 0.0 { width } else { 1.0 },
      if height > 0.0 { height } else { 1.0 },
    ),
    panel_limit: limit,
    titles: [],
  }
}

///|
pub fn Dashboard::add_panel(self : Dashboard, title : String) -> Dashboard {
  if self.titles.length() >= self.panel_limit {
    return self
  }
  let titles = self.titles.copy()
  titles.push(title)
  { ..self, titles, }
}

///|
pub fn Dashboard::panel_count(self : Dashboard) -> Int {
  self.titles.length()
}

///|
pub fn Dashboard::panel(self : Dashboard, index : Int) -> DashboardPanel {
  if index < 0 || index >= self.titles.length() {
    return { title: "", bounds: self.grid.panel(-1), index: -1 }
  }
  {
    title: self.titles[index],
    bounds: self.grid.panel(index),
    index,
  }
}

///|
pub fn Dashboard::content_bounds(self : Dashboard) -> Rect {
  self.grid.content_bounds()
}

///|
pub fn Dashboard::set_gap(
  self : Dashboard,
  horizontal : Double,
  vertical : Double,
) -> Dashboard {
  { ..self, grid: self.grid.set_gap(horizontal, vertical), }
}

///|
pub fn Dashboard::set_margins(
  self : Dashboard,
  left : Double,
  right : Double,
  top : Double,
  bottom : Double,
) -> Dashboard {
  { ..self, grid: self.grid.set_margins(left, right, top, bottom), }
}
