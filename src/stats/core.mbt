///|
/// A named numeric column that can be passed directly to chart builders or
/// analysed before rendering. Values are kept in insertion order.
pub(all) struct NumericSeries {
  name : String
  data : Array[Double]
}

///|
pub fn NumericSeries::new(
  name : String,
  values : Array[Double],
) -> NumericSeries {
  { name, data: values.copy() }
}

///|
pub fn NumericSeries::name(self : NumericSeries) -> String {
  self.name
}

///|
pub fn NumericSeries::values(self : NumericSeries) -> Array[Double] {
  self.data.copy()
}

///|
pub fn NumericSeries::length(self : NumericSeries) -> Int {
  self.data.length()
}

///|
pub fn NumericSeries::is_empty(self : NumericSeries) -> Bool {
  self.data.length() == 0
}

///|
pub fn NumericSeries::sum(self : NumericSeries) -> Double {
  let mut total = 0.0
  for value in self.data {
    total = total + value
  }
  total
}

///|
pub fn NumericSeries::mean(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  self.sum() / self.data.length().to_double()
}

///|
pub fn NumericSeries::min(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  let mut result = self.data[0]
  for i = 1; i < self.data.length(); i = i + 1 {
    if self.data[i] < result {
      result = self.data[i]
    }
  }
  result
}

///|
pub fn NumericSeries::max(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  let mut result = self.data[0]
  for i = 1; i < self.data.length(); i = i + 1 {
    if self.data[i] > result {
      result = self.data[i]
    }
  }
  result
}

///|
pub fn NumericSeries::variance(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  let average = self.mean()
  let mut total = 0.0
  for value in self.data {
    let delta = value - average
    total = total + delta * delta
  }
  total / self.data.length().to_double()
}

///|
pub fn NumericSeries::stddev(self : NumericSeries) -> Double {
  @math.pow(self.variance(), 0.5)
}

///|
pub(all) struct Summary {
  count : Int
  min : Double
  max : Double
  mean : Double
  median : Double
  variance : Double
  stddev : Double
}

///|
pub fn NumericSeries::summary(self : NumericSeries) -> Summary {
  let count = self.data.length()
  if count == 0 {
    return {
      count: 0,
      min: 0.0,
      max: 0.0,
      mean: 0.0,
      median: 0.0,
      variance: 0.0,
      stddev: 0.0,
    }
  }
  let sorted = self.data.copy()
  sorted.sort()
  let median = if count % 2 == 1 {
    sorted[count / 2]
  } else {
    (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
  }
  {
    count,
    min: self.min(),
    max: self.max(),
    mean: self.mean(),
    median,
    variance: self.variance(),
    stddev: self.stddev(),
  }
}

///|
pub fn NumericSeries::quantile(
  self : NumericSeries,
  probability : Double,
) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  let q = if probability < 0.0 {
    0.0
  } else if probability > 1.0 {
    1.0
  } else {
    probability
  }
  let sorted = self.data.copy()
  sorted.sort()
  let position = q * (sorted.length() - 1).to_double()
  let lower = @math.floor(position).to_int()
  let upper = @math.ceil(position).to_int()
  if lower == upper {
    sorted[lower]
  } else {
    let weight = position - lower.to_double()
    sorted[lower] * (1.0 - weight) + sorted[upper] * weight
  }
}
