///|
pub fn NumericSeries::map_values(
  self : NumericSeries,
  transform : (Double) -> Double,
) -> NumericSeries {
  let values : Array[Double] = []
  for value in self.data {
    values.push(transform(value))
  }
  NumericSeries::new(self.name, values)
}

///|
pub fn NumericSeries::scale(
  self : NumericSeries,
  factor : Double,
) -> NumericSeries {
  self.map_values(fn(value) { value * factor })
}

///|
pub fn NumericSeries::shift(
  self : NumericSeries,
  offset : Double,
) -> NumericSeries {
  self.map_values(fn(value) { value + offset })
}

///|
pub fn NumericSeries::normalize(self : NumericSeries) -> NumericSeries {
  let low = self.min()
  let high = self.max()
  let span = high - low
  if span == 0.0 {
    return self.map_values(fn(_) { 0.0 })
  }
  self.map_values(fn(value) { (value - low) / span })
}

///|
pub fn NumericSeries::clip(
  self : NumericSeries,
  lower : Double,
  upper : Double,
) -> NumericSeries {
  let low = if lower <= upper { lower } else { upper }
  let high = if lower <= upper { upper } else { lower }
  self.map_values(fn(value) {
    if value < low {
      low
    } else if value > high {
      high
    } else {
      value
    }
  })
}

///|
pub fn NumericSeries::take(self : NumericSeries, count : Int) -> NumericSeries {
  let final_count = if count < 0 {
    0
  } else if count > self.data.length() {
    self.data.length()
  } else {
    count
  }
  let values : Array[Double] = []
  for i = 0; i < final_count; i = i + 1 {
    values.push(self.data[i])
  }
  NumericSeries::new(self.name, values)
}

///|
pub fn NumericSeries::slice(
  self : NumericSeries,
  start : Int,
  end : Int,
) -> NumericSeries {
  let low = if start < 0 { 0 } else { start }
  let high = if end > self.data.length() { self.data.length() } else { end }
  let values : Array[Double] = []
  if low >= high {
    return NumericSeries::new(self.name, values)
  }
  for i = low; i < high; i = i + 1 {
    values.push(self.data[i])
  }
  NumericSeries::new(self.name, values)
}

///|
pub fn NumericSeries::moving_average(
  self : NumericSeries,
  window : Int,
) -> NumericSeries {
  let output : Array[Double] = []
  if window <= 0 {
    return NumericSeries::new(self.name, output)
  }
  for i = 0; i < self.data.length(); i = i + 1 {
    let start = if i + 1 > window { i + 1 - window } else { 0 }
    let mut total = 0.0
    for j = start; j <= i; j = j + 1 {
      total = total + self.data[j]
    }
    output.push(total / (i - start + 1).to_double())
  }
  NumericSeries::new(self.name + " (moving average)", output)
}

///|
pub fn NumericSeries::difference(self : NumericSeries) -> NumericSeries {
  let output : Array[Double] = []
  if self.data.length() == 0 {
    return NumericSeries::new(self.name + " (difference)", output)
  }
  output.push(0.0)
  for i = 1; i < self.data.length(); i = i + 1 {
    output.push(self.data[i] - self.data[i - 1])
  }
  NumericSeries::new(self.name + " (difference)", output)
}

///|
pub fn NumericSeries::correlation(
  self : NumericSeries,
  other : NumericSeries,
) -> Double {
  let count = if self.data.length() < other.data.length() {
    self.data.length()
  } else {
    other.data.length()
  }
  if count < 2 {
    return 0.0
  }
  let mut left_mean = 0.0
  let mut right_mean = 0.0
  for i = 0; i < count; i = i + 1 {
    left_mean = left_mean + self.data[i]
    right_mean = right_mean + other.data[i]
  }
  left_mean = left_mean / count.to_double()
  right_mean = right_mean / count.to_double()
  let mut covariance = 0.0
  let mut left_variance = 0.0
  let mut right_variance = 0.0
  for i = 0; i < count; i = i + 1 {
    let left_delta = self.data[i] - left_mean
    let right_delta = other.data[i] - right_mean
    covariance = covariance + left_delta * right_delta
    left_variance = left_variance + left_delta * left_delta
    right_variance = right_variance + right_delta * right_delta
  }
  if left_variance == 0.0 || right_variance == 0.0 {
    return 0.0
  }
  covariance / @math.pow(left_variance * right_variance, 0.5)
}
