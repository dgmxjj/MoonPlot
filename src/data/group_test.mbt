///|
test "group_numeric_summarizes_real_categories_deterministically" {
  let table = CsvTable::parse(
    "region,latency\neast,10\nwest,20\neast,14\nwest,\n",
  ).unwrap()
  let groups = table.group_numeric("region", "latency").unwrap()
  assert_eq(groups.length(), 2)
  assert_eq(groups[0].key, "east")
  assert_eq(groups[0].count, 2)
  assert_eq(groups[0].sum, 24.0)
  assert_eq(groups[0].mean, 12.0)
  assert_eq(groups[1].key, "west")
  assert_eq(groups[1].count, 1)
  assert_eq(groups[1].min, 20.0)
}

///|
test "group_numeric_reports_missing_columns_and_bad_numbers" {
  let table = CsvTable::parse("kind,value\na,not-a-number").unwrap()
  match table.group_numeric("missing", "value") {
    Ok(_) => assert_true(false)
    Err(CsvError::MissingColumn(name)) => assert_eq(name, "missing")
    Err(_) => assert_true(false)
  }
  match table.group_numeric("kind", "value") {
    Ok(_) => assert_true(false)
    Err(CsvError::InvalidNumber(line)) => assert_eq(line, 2)
    Err(_) => assert_true(false)
  }
}
