///|
/// A deterministic two-dimensional numeric pivot table.
pub(all) struct PivotTable {
  row_keys : Array[String]
  column_keys : Array[String]
  values : Array[Array[Double]]
}

///|
pub fn CsvTable::pivot_numeric(
  self : CsvTable,
  row_column : String,
  column_column : String,
  value_column : String,
) -> Result[PivotTable, CsvError] {
  let row_index = self.header_index(row_column)
  let column_index = self.header_index(column_column)
  let value_index = self.header_index(value_column)
  if row_index < 0 {
    return Err(CsvError::MissingColumn(row_column))
  }
  if column_index < 0 {
    return Err(CsvError::MissingColumn(column_column))
  }
  if value_index < 0 {
    return Err(CsvError::MissingColumn(value_column))
  }
  let row_keys : Array[String] = []
  let column_keys : Array[String] = []
  for row in self.rows {
    let row_key = row[row_index]
    let column_key = row[column_index]
    if row_key != "" && !row_keys.contains(row_key) {
      row_keys.push(row_key)
    }
    if column_key != "" && !column_keys.contains(column_key) {
      column_keys.push(column_key)
    }
  }
  let values : Array[Array[Double]] = []
  for _ in row_keys {
    let output_row : Array[Double] = []
    for _ in column_keys {
      output_row.push(0.0)
    }
    values.push(output_row)
  }
  for row_index_in_source = 0; row_index_in_source < self.rows.length(); row_index_in_source =
    row_index_in_source + 1 {
    let row = self.rows[row_index_in_source]
    let row_key = row[row_index]
    let column_key = row[column_index]
    let raw_value = row[value_index]
    if row_key == "" || column_key == "" || raw_value == "" {
      continue
    }
    let value = try @string.parse_double(raw_value) catch {
      _ => return Err(CsvError::InvalidNumber(row_index_in_source + 2))
    }
    let target_row = pivot_index(row_keys, row_key)
    let target_column = pivot_index(column_keys, column_key)
    if target_row >= 0 && target_column >= 0 {
      values[target_row][target_column] = value
    }
  }
  Ok({ row_keys, column_keys, values })
}

///|
pub fn PivotTable::row_count(self : PivotTable) -> Int {
  self.row_keys.length()
}

///|
pub fn PivotTable::column_count(self : PivotTable) -> Int {
  self.column_keys.length()
}

///|
pub fn PivotTable::row_key(self : PivotTable, index : Int) -> String {
  if index < 0 || index >= self.row_keys.length() {
    return ""
  }
  self.row_keys[index]
}

///|
pub fn PivotTable::column_key(self : PivotTable, index : Int) -> String {
  if index < 0 || index >= self.column_keys.length() {
    return ""
  }
  self.column_keys[index]
}

///|
pub fn PivotTable::cell(self : PivotTable, row : Int, column : Int) -> Double {
  if row < 0 || row >= self.values.length() {
    return 0.0
  }
  if column < 0 || column >= self.values[row].length() {
    return 0.0
  }
  self.values[row][column]
}

///|
pub fn PivotTable::minimum(self : PivotTable) -> Double {
  let mut result = 0.0
  let mut initialized = false
  for row in self.values {
    for value in row {
      if !initialized || value < result {
        result = value
        initialized = true
      }
    }
  }
  result
}

///|
pub fn PivotTable::maximum(self : PivotTable) -> Double {
  let mut result = 0.0
  let mut initialized = false
  for row in self.values {
    for value in row {
      if !initialized || value > result {
        result = value
        initialized = true
      }
    }
  }
  result
}

///|
fn pivot_index(keys : Array[String], key : String) -> Int {
  for i = 0; i < keys.length(); i = i + 1 {
    if keys[i] == key {
      return i
    }
  }
  -1
}
