///|
/// A stable classification for a table column. Empty cells are tracked
/// separately, so a numeric column may still contain missing observations.
pub(all) enum ColumnKind {
  Empty
  Numeric
  Categorical
  Mixed
} derive(Eq)

///|
/// A deterministic frequency entry for a non-empty categorical value.
pub(all) struct CategoryCount {
  value : String
  count : Int
}

///|
/// A compact, dependency-free description of one CSV column.
pub(all) struct ColumnProfile {
  name : String
  kind : ColumnKind
  row_count : Int
  missing_count : Int
  numeric_count : Int
  distinct_count : Int
  numeric_min : Double
  numeric_max : Double
  numeric_mean : Double
  categories : Array[CategoryCount]
}

///|
pub fn ColumnProfile::category_counts(self : ColumnProfile) -> Array[CategoryCount] {
  self.categories.copy()
}

///|
/// A profile for every column in source order.
pub(all) struct TableProfile {
  row_count : Int
  column_count : Int
  columns : Array[ColumnProfile]
}

///|
pub fn TableProfile::column(self : TableProfile, name : String) -> ColumnProfile? {
  for column in self.columns {
    if column.name == name {
      return Some(column)
    }
  }
  None
}

///|
/// Profile a table without file-system or renderer dependencies. Numeric
/// columns accept missing cells, while a mixture of numbers and text is
/// marked `Mixed` so callers do not accidentally treat it as numeric data.
pub fn CsvTable::profile(self : CsvTable) -> TableProfile {
  let columns : Array[ColumnProfile] = []
  for column_index = 0; column_index < self.header.length(); column_index =
    column_index + 1 {
    let name = self.header[column_index]
    let mut missing_count = 0
    let mut numeric_count = 0
    let mut invalid_count = 0
    let mut numeric_total = 0.0
    let mut numeric_min = 0.0
    let mut numeric_max = 0.0
    let distinct_values : Array[String] = []
    let category_counts : Array[CategoryCount] = []
    for row in self.rows {
      let value = row[column_index]
      if value == "" {
        missing_count = missing_count + 1
      } else {
        if !distinct_values.contains(value) {
          distinct_values.push(value)
        }
        let parsed : Double? = try Some(@string.parse_double(value)) catch {
          _ => None
        }
        match parsed {
          Some(number) => {
            numeric_count = numeric_count + 1
            numeric_total = numeric_total + number
            if numeric_count == 1 {
              numeric_min = number
              numeric_max = number
            } else {
              if number < numeric_min {
                numeric_min = number
              }
              if number > numeric_max {
                numeric_max = number
              }
            }
          }
          None => {
            invalid_count = invalid_count + 1
            add_category_count(category_counts, value)
          }
        }
      }
    }
    let row_count = self.rows.length()
    let nonempty_count = row_count - missing_count
    let kind = if nonempty_count == 0 {
      ColumnKind::Empty
    } else if invalid_count == 0 {
      ColumnKind::Numeric
    } else if numeric_count == 0 {
      ColumnKind::Categorical
    } else {
      ColumnKind::Mixed
    }
    let mean = if numeric_count == 0 {
      0.0
    } else {
      numeric_total / numeric_count.to_double()
    }
    columns.push({
      name,
      kind,
      row_count,
      missing_count,
      numeric_count,
      distinct_count: distinct_values.length(),
      numeric_min,
      numeric_max,
      numeric_mean: mean,
      categories: category_counts,
    })
  }
  {
    row_count: self.rows.length(),
    column_count: self.header.length(),
    columns,
  }
}

///|
fn add_category_count(counts : Array[CategoryCount], value : String) -> Unit {
  for i = 0; i < counts.length(); i = i + 1 {
    if counts[i].value == value {
      let current = counts[i]
      counts[i] = { ..current, count: current.count + 1 }
      return
    }
  }
  counts.push({ value, count: 1 })
}
