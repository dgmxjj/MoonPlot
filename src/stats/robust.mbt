///|
pub fn NumericSeries::median_absolute_deviation(self : NumericSeries) -> Double {
  if self.data.length() == 0 {
    return 0.0
  }
  let center = self.quantile(0.5)
  let deviations : Array[Double] = []
  for value in self.data {
    let delta = value - center
    deviations.push(if delta < 0.0 { -delta } else { delta })
  }
  NumericSeries::new(self.name + " (absolute deviation)", deviations).quantile(
    0.5,
  )
}

///|
/// Return indexes whose robust deviation exceeds the supplied multiple.
pub fn NumericSeries::outlier_indices(
  self : NumericSeries,
  threshold : Double,
) -> Array[Int] {
  let output : Array[Int] = []
  let mad = self.median_absolute_deviation()
  if mad == 0.0 || threshold <= 0.0 {
    return output
  }
  let center = self.quantile(0.5)
  for i = 0; i < self.data.length(); i = i + 1 {
    let delta = self.data[i] - center
    let distance = if delta < 0.0 { -delta } else { delta }
    if distance / mad > threshold {
      output.push(i)
    }
  }
  output
}

///|
pub fn NumericSeries::rolling_min(
  self : NumericSeries,
  window : Int,
) -> NumericSeries {
  let output : Array[Double] = []
  if window <= 0 {
    return NumericSeries::new(self.name + " (rolling min)", output)
  }
  for i = 0; i < self.data.length(); i = i + 1 {
    let start = if i + 1 > window { i + 1 - window } else { 0 }
    let mut current = self.data[start]
    for j = start + 1; j <= i; j = j + 1 {
      if self.data[j] < current {
        current = self.data[j]
      }
    }
    output.push(current)
  }
  NumericSeries::new(self.name + " (rolling min)", output)
}

///|
pub fn NumericSeries::rolling_max(
  self : NumericSeries,
  window : Int,
) -> NumericSeries {
  let output : Array[Double] = []
  if window <= 0 {
    return NumericSeries::new(self.name + " (rolling max)", output)
  }
  for i = 0; i < self.data.length(); i = i + 1 {
    let start = if i + 1 > window { i + 1 - window } else { 0 }
    let mut current = self.data[start]
    for j = start + 1; j <= i; j = j + 1 {
      if self.data[j] > current {
        current = self.data[j]
      }
    }
    output.push(current)
  }
  NumericSeries::new(self.name + " (rolling max)", output)
}

///|
/// Deterministic linear downsampling for large data series.
pub fn NumericSeries::resample(
  self : NumericSeries,
  count : Int,
) -> NumericSeries {
  let output : Array[Double] = []
  if count <= 0 || self.data.length() == 0 {
    return NumericSeries::new(self.name + " (resampled)", output)
  }
  if count == 1 {
    output.push(self.data[0])
    return NumericSeries::new(self.name + " (resampled)", output)
  }
  if self.data.length() == 1 {
    let mut repeat = 0
    while repeat < count {
      output.push(self.data[0])
      repeat = repeat + 1
    }
    return NumericSeries::new(self.name + " (resampled)", output)
  }
  for i = 0; i < count; i = i + 1 {
    let position = i.to_double() *
      (self.data.length() - 1).to_double() /
      (count - 1).to_double()
    let lower = @math.floor(position).to_int()
    let upper = @math.ceil(position).to_int()
    if lower == upper {
      output.push(self.data[lower])
    } else {
      let weight = position - lower.to_double()
      output.push(self.data[lower] * (1.0 - weight) + self.data[upper] * weight)
    }
  }
  NumericSeries::new(self.name + " (resampled)", output)
}
