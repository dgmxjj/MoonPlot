///|
test "pivot_numeric_builds_stable_matrix_from_two_categories" {
  let table = CsvTable::parse(
    "region,metric,value\neast,latency,10\neast,throughput,100\nwest,latency,20\n",
  ).unwrap()
  let pivot = table.pivot_numeric("region", "metric", "value").unwrap()
  assert_eq(pivot.row_count(), 2)
  assert_eq(pivot.column_count(), 2)
  assert_eq(pivot.row_key(0), "east")
  assert_eq(pivot.column_key(1), "throughput")
  assert_eq(pivot.cell(0, 0), 10.0)
  assert_eq(pivot.cell(1, 1), 0.0)
  assert_eq(pivot.maximum(), 100.0)
}

///|
test "pivot_numeric_skips_missing_cells_and_reports_bad_input" {
  let table = CsvTable::parse("a,b,c\nx,y,bad").unwrap()
  match table.pivot_numeric("missing", "b", "c") {
    Ok(_) => assert_true(false)
    Err(CsvError::MissingColumn(name)) => assert_eq(name, "missing")
    Err(_) => assert_true(false)
  }
  match table.pivot_numeric("a", "b", "c") {
    Ok(_) => assert_true(false)
    Err(CsvError::InvalidNumber(line)) => assert_eq(line, 2)
    Err(_) => assert_true(false)
  }
}
