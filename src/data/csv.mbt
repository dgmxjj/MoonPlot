///|
/// Errors are deliberately small and deterministic so callers can show a
/// useful validation message without depending on file-system exceptions.
pub(all) enum CsvError {
  EmptyInput
  UnterminatedQuote(Int)
  InconsistentColumns(Int)
  InvalidNumber(Int)
  MissingColumn(String)
}

///|
/// A parsed CSV table. The parser is string based: applications decide how
/// to obtain the bytes, while the chart library remains portable across all
/// MoonBit targets.
pub(all) struct CsvTable {
  header : Array[String]
  rows : Array[Array[String]]
}

///|
pub fn CsvTable::parse(input : String) -> Result[CsvTable, CsvError] {
  if input == "" {
    return Err(CsvError::EmptyInput)
  }
  let chars = input.to_array()
  let rows : Array[Array[String]] = []
  let mut row : Array[String] = []
  let field_chars : Array[Char] = []
  let mut quoted = false
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if quoted {
      if c == '"' {
        if i + 1 < chars.length() && chars[i + 1] == '"' {
          field_chars.push('"')
          i = i + 2
        } else {
          quoted = false
          i = i + 1
        }
      } else {
        field_chars.push(c)
        i = i + 1
      }
    } else if c == '"' && field_chars.length() == 0 {
      quoted = true
      i = i + 1
    } else if c == ',' {
      row.push(String::from_array(field_chars))
      field_chars.clear()
      i = i + 1
    } else if c == '\n' {
      row.push(String::from_array(field_chars))
      field_chars.clear()
      if row.length() > 1 || row[0] != "" {
        rows.push(row)
      }
      row = []
      i = i + 1
    } else if c == '\r' {
      if i + 1 < chars.length() && chars[i + 1] == '\n' {
        i = i + 1
      } else {
        field_chars.push(c)
      }
      i = i + 1
    } else {
      field_chars.push(c)
      i = i + 1
    }
  }
  if quoted {
    return Err(CsvError::UnterminatedQuote(rows.length() + 1))
  }
  if row.length() > 0 || field_chars.length() > 0 {
    row.push(String::from_array(field_chars))
    if row.length() > 1 || row[0] != "" {
      rows.push(row)
    }
  }
  if rows.length() == 0 {
    return Ok({ header: [], rows: [] })
  }
  let header = rows[0]
  let expected = header.length()
  let data : Array[Array[String]] = []
  for index = 1; index < rows.length(); index = index + 1 {
    if rows[index].length() != expected {
      return Err(CsvError::InconsistentColumns(index + 1))
    }
    data.push(rows[index])
  }
  Ok({ header, rows: data })
}

///|
pub fn CsvTable::headers(self : CsvTable) -> Array[String] {
  self.header.copy()
}

///|
pub fn CsvTable::row_count(self : CsvTable) -> Int {
  self.rows.length()
}

///|
pub fn CsvTable::column_count(self : CsvTable) -> Int {
  self.header.length()
}

///|
pub fn CsvTable::has_column(self : CsvTable, name : String) -> Bool {
  for header in self.header {
    if header == name {
      return true
    }
  }
  false
}

///|
/// Return an empty string for a missing coordinate. This is intentional for
/// visualization pipelines, where an absent label should become a missing
/// value rather than crash a whole render operation.
pub fn CsvTable::cell(self : CsvTable, row : Int, column : Int) -> String {
  if row < 0 || row >= self.rows.length() {
    return ""
  }
  if column < 0 || column >= self.rows[row].length() {
    return ""
  }
  self.rows[row][column]
}

///|
pub fn CsvTable::column(self : CsvTable, name : String) -> Array[String] {
  let mut index = -1
  for i = 0; i < self.header.length(); i = i + 1 {
    if self.header[i] == name {
      index = i
      break
    }
  }
  let values : Array[String] = []
  if index < 0 {
    return values
  }
  for row in self.rows {
    values.push(row[index])
  }
  values
}

///|
/// Parse one named column without coupling the table to a chart type.
pub fn CsvTable::numeric_column(
  self : CsvTable,
  name : String,
) -> Result[Array[Double], CsvError] {
  let values = self.column(name)
  let expected = self.header.length()
  let mut index = -1
  for i = 0; i < expected; i = i + 1 {
    if self.header[i] == name {
      index = i
      break
    }
  }
  if index < 0 {
    return Ok([])
  }
  let output : Array[Double] = []
  for i = 0; i < values.length(); i = i + 1 {
    let value = values[i]
    let parsed = @string.parse_double(value) catch {
      _ => return Err(CsvError::InvalidNumber(i + 2))
    }
    output.push(parsed)
  }
  Ok(output)
}

///|
/// Filter rows without changing column order or the original table.
pub fn CsvTable::filter_equals(
  self : CsvTable,
  column_name : String,
  expected : String,
) -> CsvTable {
  let column = self.header_index(column_name)
  let selected : Array[Array[String]] = []
  if column < 0 {
    return { header: self.header.copy(), rows: selected }
  }
  for row in self.rows {
    if row[column] == expected {
      selected.push(row.copy())
    }
  }
  { header: self.header.copy(), rows: selected }
}

///|
/// Select and reorder columns while preserving the source rows.
pub fn CsvTable::select_columns(
  self : CsvTable,
  names : Array[String],
) -> Result[CsvTable, CsvError] {
  let indexes : Array[Int] = []
  for name in names {
    let index = self.header_index(name)
    if index < 0 {
      return Err(CsvError::MissingColumn(name))
    }
    indexes.push(index)
  }
  let rows : Array[Array[String]] = []
  for source_row in self.rows {
    let row : Array[String] = []
    for index in indexes {
      row.push(source_row[index])
    }
    rows.push(row)
  }
  Ok({ header: names.copy(), rows })
}

///|
fn CsvTable::header_index(self : CsvTable, name : String) -> Int {
  for i = 0; i < self.header.length(); i = i + 1 {
    if self.header[i] == name {
      return i
    }
  }
  -1
}

///|
pub fn CsvTable::is_empty(self : CsvTable) -> Bool {
  self.rows.length() == 0
}

///|
pub fn CsvTable::to_csv(self : CsvTable) -> String {
  let mut output = join_csv_row(self.header)
  for row in self.rows {
    output = output + "\n" + join_csv_row(row)
  }
  output
}

///|
fn join_csv_row(row : Array[String]) -> String {
  let mut output = ""
  for i = 0; i < row.length(); i = i + 1 {
    if i > 0 {
      output = output + ","
    }
    output = output + quote_csv_field(row[i])
  }
  output
}

///|
fn quote_csv_field(value : String) -> String {
  if value.contains(",") || value.contains("\n") || value.contains("\"") {
    "\"" + value.replace_all(old="\"", new="\"\"") + "\""
  } else {
    value
  }
}
