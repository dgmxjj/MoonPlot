///|
test "csv_parser_handles_headers_quotes_and_empty_fields" {
  let input = "name,value,note\nalpha,1.5,\"fast, stable\"\nbeta,,\"quoted \"\"text\"\"\""
  match CsvTable::parse(input) {
    Ok(table) => {
      assert_eq(table.headers()[0], "name")
      assert_eq(table.headers()[1], "value")
      assert_eq(table.headers()[2], "note")
      assert_eq(table.row_count(), 2)
      assert_eq(table.cell(0, 2), "fast, stable")
      assert_eq(table.cell(1, 1), "")
    }
    Err(_) => assert_true(false)
  }
}

///|
test "csv_parser_reports_inconsistent_row_number" {
  match CsvTable::parse("a,b\n1,2\n3") {
    Ok(_) => assert_true(false)
    Err(CsvError::InconsistentColumns(line)) => assert_eq(line, 3)
    Err(_) => assert_true(false)
  }
}

///|
test "csv_parser_handles_newline_and_empty_input_boundaries" {
  match CsvTable::parse("\n") {
    Ok(table) => assert_eq(table.row_count(), 0)
    Err(_) => assert_true(false)
  }
  match CsvTable::parse("") {
    Ok(_) => assert_true(false)
    Err(CsvError::EmptyInput) => assert_true(true)
    Err(_) => assert_true(false)
  }
}

///|
test "csv_parser_converts_numeric_columns_with_row_errors" {
  let table = CsvTable::parse("time,value\n1,2.5\n2,3.5").unwrap()
  match table.numeric_column("value") {
    Ok(values) => {
      assert_eq(values[0], 2.5)
      assert_eq(values[1], 3.5)
    }
    Err(_) => assert_true(false)
  }
  match CsvTable::parse("time,value\n1,nope").unwrap().numeric_column("value") {
    Ok(_) => assert_true(false)
    Err(CsvError::InvalidNumber(line)) => assert_eq(line, 2)
    Err(_) => assert_true(false)
  }
}

///|
test "csv_table_supports_reproducible_selection_and_filtering" {
  let table = CsvTable::parse("species,value\na,1\nb,2\na,3").unwrap()
  assert_eq(table.has_column("value"), true)
  assert_eq(table.has_column("missing"), false)
  let filtered = table.filter_equals("species", "a")
  assert_eq(filtered.row_count(), 2)
  assert_eq(filtered.cell(1, 1), "3")
  match table.select_columns(["value", "species"]) {
    Ok(selected) => {
      assert_eq(selected.column_count(), 2)
      assert_eq(selected.cell(0, 0), "1")
    }
    Err(_) => assert_true(false)
  }
  assert_true(table.to_csv().contains("species,value"))
}
