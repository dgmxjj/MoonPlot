///|
/// A normalized numeric extent used for autoscaling and axis generation.
pub(all) struct NumericDomain {
  lower : Double
  upper : Double
}

///|
pub fn NumericDomain::new(first : Double, second : Double) -> NumericDomain {
  if first <= second {
    { lower: first, upper: second }
  } else {
    { lower: second, upper: first }
  }
}

///|
pub fn NumericDomain::from_values(values : Array[Double]) -> NumericDomain {
  if values.length() == 0 {
    return { lower: 0.0, upper: 1.0 }
  }
  let mut low = values[0]
  let mut high = values[0]
  for i = 1; i < values.length(); i = i + 1 {
    if values[i] < low {
      low = values[i]
    }
    if values[i] > high {
      high = values[i]
    }
  }
  { lower: low, upper: high }
}

///|
pub fn NumericDomain::min(self : NumericDomain) -> Double {
  self.lower
}

///|
pub fn NumericDomain::max(self : NumericDomain) -> Double {
  self.upper
}

///|
pub fn NumericDomain::span(self : NumericDomain) -> Double {
  self.upper - self.lower
}

///|
pub fn NumericDomain::contains(self : NumericDomain, value : Double) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
pub fn NumericDomain::pad(
  self : NumericDomain,
  fraction : Double,
) -> NumericDomain {
  let safe_fraction = if fraction > 0.0 { fraction } else { 0.0 }
  let amount = if self.span() == 0.0 {
    if self.lower == 0.0 {
      1.0
    } else {
      self.lower.abs() * safe_fraction
    }
  } else {
    self.span() * safe_fraction
  }
  NumericDomain::new(self.lower - amount, self.upper + amount)
}

///|
/// Choose a 1/2/5×10^n step and expand the extent to tick boundaries.
pub fn NumericDomain::nice(
  self : NumericDomain,
  target_ticks : Int,
) -> NumericDomain {
  if target_ticks <= 1 {
    return self
  }
  let span = if self.span() > 0.0 { self.span() } else { 1.0 }
  let raw_step = span / target_ticks.to_double()
  let exponent = @math.floor(@math.log10(raw_step))
  let power = @math.pow(10.0, exponent)
  let fraction = raw_step / power
  let nice_fraction = if fraction <= 1.0 {
    1.0
  } else if fraction <= 2.0 {
    2.0
  } else if fraction <= 5.0 {
    5.0
  } else {
    10.0
  }
  let step = nice_fraction * power
  let low = @math.floor(self.lower / step) * step
  let high = @math.ceil(self.upper / step) * step
  NumericDomain::new(low, high)
}

///|
pub fn NumericDomain::ticks(self : NumericDomain, count : Int) -> Array[Double] {
  let output : Array[Double] = []
  if count <= 1 {
    return output
  }
  let step = self.span() / (count - 1).to_double()
  for i = 0; i < count; i = i + 1 {
    output.push(self.lower + step * i.to_double())
  }
  output
}

///|
pub fn NumericDomain::clamp(self : NumericDomain, value : Double) -> Double {
  if value < self.lower {
    self.lower
  } else if value > self.upper {
    self.upper
  } else {
    value
  }
}

///|
pub fn NumericDomain::normalize(self : NumericDomain, value : Double) -> Double {
  if self.span() == 0.0 {
    0.0
  } else {
    (value - self.lower) / self.span()
  }
}
