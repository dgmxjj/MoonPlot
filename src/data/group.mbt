///|
/// A deterministic aggregation of one numeric column grouped by a label.
pub(all) struct GroupSummary {
  key : String
  count : Int
  sum : Double
  mean : Double
  min : Double
  max : Double
}

///|
/// Group rows by `group_column` and summarize `value_column`. Empty labels
/// and empty measurements are skipped; malformed numeric values report their
/// original CSV data line so callers can fix the source deterministically.
pub fn CsvTable::group_numeric(
  self : CsvTable,
  group_column : String,
  value_column : String,
) -> Result[Array[GroupSummary], CsvError] {
  let group_index = self.header_index(group_column)
  if group_index < 0 {
    return Err(CsvError::MissingColumn(group_column))
  }
  let value_index = self.header_index(value_column)
  if value_index < 0 {
    return Err(CsvError::MissingColumn(value_column))
  }
  let groups : Array[GroupSummary] = []
  for row_index = 0; row_index < self.rows.length(); row_index = row_index + 1 {
    let row = self.rows[row_index]
    let key = row[group_index]
    let raw_value = row[value_index]
    if key == "" || raw_value == "" {
      continue
    }
    let value = try @string.parse_double(raw_value) catch {
      _ => return Err(CsvError::InvalidNumber(row_index + 2))
    }
    let existing = find_group(groups, key)
    if existing < 0 {
      groups.push({ key, count: 1, sum: value, mean: value, min: value, max: value })
    } else {
      let current = groups[existing]
      let next_count = current.count + 1
      let next_sum = current.sum + value
      let next_min = if value < current.min { value } else { current.min }
      let next_max = if value > current.max { value } else { current.max }
      groups[existing] = {
        ..current,
        count: next_count,
        sum: next_sum,
        mean: next_sum / next_count.to_double(),
        min: next_min,
        max: next_max,
      }
    }
  }
  Ok(groups)
}

///|
fn find_group(groups : Array[GroupSummary], key : String) -> Int {
  for i = 0; i < groups.length(); i = i + 1 {
    if groups[i].key == key {
      return i
    }
  }
  -1
}
