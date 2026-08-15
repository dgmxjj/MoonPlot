///|
test "table_profile_classifies_numeric_categorical_and_missing_columns" {
  let table = CsvTable::parse(
    "name,value,group\na,1.5,x\nb,,x\nc,3.5,y",
  ).unwrap()
  let profile = table.profile()
  assert_eq(profile.row_count, 3)
  assert_eq(profile.column_count, 3)
  assert_true(profile.columns[0].kind is ColumnKind::Categorical)
  assert_eq(profile.columns[0].missing_count, 0)
  assert_true(profile.columns[1].kind is ColumnKind::Numeric)
  assert_eq(profile.columns[1].missing_count, 1)
  assert_eq(profile.columns[1].numeric_count, 2)
  assert_eq(profile.columns[1].numeric_mean, 2.5)
  assert_eq(profile.columns[2].distinct_count, 2)
  assert_eq(profile.columns[2].category_counts()[0].count, 2)
}

///|
test "table_profile_reports_mixed_empty_and_invalid_columns" {
  let table = CsvTable::parse(
    "empty,mixed,invalid\n,,nope\n,2.0,\n,hello,",
  ).unwrap()
  let profile = table.profile()
  assert_true(profile.columns[0].kind is ColumnKind::Empty)
  assert_eq(profile.columns[0].missing_count, 3)
  assert_true(profile.columns[1].kind is ColumnKind::Mixed)
  assert_true(profile.columns[2].kind is ColumnKind::Categorical)
  assert_eq(profile.columns[2].distinct_count, 1)
}

///|
test "column_profile_handles_invalid_index_and_stable_categories" {
  let table = CsvTable::parse("kind\nb\na\nb\n").unwrap()
  let profile = table.profile()
  assert_eq(profile.column("kind").unwrap().category_counts()[0].value, "b")
  assert_eq(profile.column("kind").unwrap().category_counts()[1].value, "a")
  assert_true(profile.column("missing") is None)
}
