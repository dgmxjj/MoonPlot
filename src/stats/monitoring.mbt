///|
pub fn Summary::range(self : Summary) -> Double {
  self.max - self.min
}

///|
/// Return zero for a zero mean so dashboards never emit infinity.
pub fn Summary::coefficient_of_variation(self : Summary) -> Double {
  if self.mean == 0.0 {
    0.0
  } else {
    self.stddev / @math.pow(self.mean * self.mean, 0.5)
  }
}

///|
pub fn Summary::is_constant(self : Summary) -> Bool {
  self.count == 0 || self.min == self.max
}

///|
pub fn NumericSeries::cumulative_sum(self : NumericSeries) -> NumericSeries {
  let output : Array[Double] = []
  let mut total = 0.0
  for value in self.data {
    total = total + value
    output.push(total)
  }
  NumericSeries::new(self.name + " (cumulative)", output)
}

///|
/// Percentage change from the previous sample; a zero previous sample yields
/// zero because an infinite percentage is not useful in a chart axis.
pub fn NumericSeries::percent_change(self : NumericSeries) -> NumericSeries {
  let output : Array[Double] = []
  if self.data.length() == 0 {
    return NumericSeries::new(self.name + " (% change)", output)
  }
  output.push(0.0)
  for i = 1; i < self.data.length(); i = i + 1 {
    let previous = self.data[i - 1]
    if previous == 0.0 {
      output.push(0.0)
    } else {
      output.push(
        (self.data[i] - previous) / @math.pow(previous * previous, 0.5) * 100.0,
      )
    }
  }
  NumericSeries::new(self.name + " (% change)", output)
}

///|
pub fn NumericSeries::exponential_moving_average(
  self : NumericSeries,
  alpha : Double,
) -> NumericSeries {
  let output : Array[Double] = []
  if self.data.length() == 0 {
    return NumericSeries::new(self.name + " (EMA)", output)
  }
  let weight = if alpha < 0.0 { 0.0 } else if alpha > 1.0 { 1.0 } else { alpha }
  let mut previous = self.data[0]
  output.push(previous)
  for i = 1; i < self.data.length(); i = i + 1 {
    previous = weight * self.data[i] + (1.0 - weight) * previous
    output.push(previous)
  }
  NumericSeries::new(self.name + " (EMA)", output)
}
