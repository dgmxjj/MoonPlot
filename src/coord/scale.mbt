///|
pub trait Scale {
  fn map(self : Self, value : Double) -> Double
  fn generate_ticks(self : Self, count : Int) -> Array[Double]
}

// ==========================================
// LinearScale
// ==========================================

///|
pub struct LinearScale {
  domain_min : Double
  domain_max : Double
  range_min : Double
  range_max : Double
}

///|
pub fn LinearScale::new(
  dmin : Double,
  dmax : Double,
  rmin : Double,
  rmax : Double,
) -> LinearScale {
  { domain_min: dmin, domain_max: dmax, range_min: rmin, range_max: rmax }
}

///|
pub fn LinearScale::map(self : LinearScale, value : Double) -> Double {
  if self.domain_max == self.domain_min {
    return self.range_min
  }
  let ratio = (value - self.domain_min) / (self.domain_max - self.domain_min)
  self.range_min + ratio * (self.range_max - self.range_min)
}

///|
pub fn LinearScale::generate_ticks(
  self : LinearScale,
  count : Int,
) -> Array[Double] {
  let ticks = []
  if count <= 1 {
    return ticks
  }
  let step = (self.domain_max - self.domain_min) / (count - 1).to_double()
  for i = 0; i < count; i = i + 1 {
    ticks.push(self.domain_min + step * i.to_double())
  }
  ticks
}

///|
pub impl Scale for LinearScale with fn map(self, value) {
  self.map(value)
}

///|
pub impl Scale for LinearScale with fn generate_ticks(self, count) {
  self.generate_ticks(count)
}

// ==========================================
// LogarithmicScale
// ==========================================

///|
pub struct LogarithmicScale {
  domain_min : Double
  domain_max : Double
  range_min : Double
  range_max : Double
  base : Double
}

///|
pub fn LogarithmicScale::new(
  dmin : Double,
  dmax : Double,
  rmin : Double,
  rmax : Double,
  base? : Double = 10.0,
) -> LogarithmicScale {
  let dmin_safe = if dmin <= 0.0 { 0.00001 } else { dmin }
  let dmax_safe = if dmax <= 0.0 { 1.0 } else { dmax }
  {
    domain_min: dmin_safe,
    domain_max: dmax_safe,
    range_min: rmin,
    range_max: rmax,
    base,
  }
}

///|
pub fn LogarithmicScale::map(self : LogarithmicScale, value : Double) -> Double {
  if self.domain_max == self.domain_min {
    return self.range_min
  }
  let val_safe = if value <= 0.0 { 0.00001 } else { value }
  let log_min = @math.ln(self.domain_min) / @math.ln(self.base)
  let log_max = @math.ln(self.domain_max) / @math.ln(self.base)
  let log_val = @math.ln(val_safe) / @math.ln(self.base)
  let ratio = (log_val - log_min) / (log_max - log_min)
  self.range_min + ratio * (self.range_max - self.range_min)
}

///|
pub fn LogarithmicScale::generate_ticks(
  self : LogarithmicScale,
  count : Int,
) -> Array[Double] {
  let ticks = []
  if count <= 1 {
    return ticks
  }
  let log_min = @math.ln(self.domain_min) / @math.ln(self.base)
  let log_max = @math.ln(self.domain_max) / @math.ln(self.base)
  let start = @math.floor(log_min).to_int()
  let end = @math.ceil(log_max).to_int()
  if end - start < count {
    let step = (log_max - log_min) / (count - 1).to_double()
    for i = 0; i < count; i = i + 1 {
      let val = @math.exp(
        (log_min + step * i.to_double()) * @math.ln(self.base),
      )
      ticks.push(val)
    }
  } else {
    for i = start; i <= end; i = i + 1 {
      let val = @math.pow(self.base, i.to_double())
      if val >= self.domain_min && val <= self.domain_max {
        ticks.push(val)
      }
    }
  }
  ticks
}

///|
pub impl Scale for LogarithmicScale with fn map(self, value) {
  self.map(value)
}

///|
pub impl Scale for LogarithmicScale with fn generate_ticks(self, count) {
  self.generate_ticks(count)
}

// ==========================================
// CategoryScale
// ==========================================

///|
pub struct CategoryScale {
  categories : Array[String]
  range_min : Double
  range_max : Double
}

///|
pub fn CategoryScale::new(
  categories : Array[String],
  rmin : Double,
  rmax : Double,
) -> CategoryScale {
  { categories, range_min: rmin, range_max: rmax }
}

///|
pub fn CategoryScale::map(self : CategoryScale, category : String) -> Double {
  let count = self.categories.length()
  if count == 0 {
    return self.range_min
  }
  let mut idx = -1
  for i = 0; i < count; i = i + 1 {
    if self.categories[i] == category {
      idx = i
      break
    }
  }
  if idx == -1 {
    return self.range_min
  }
  let step = (self.range_max - self.range_min) / count.to_double()
  self.range_min + step * (idx.to_double() + 0.5)
}

///|
pub fn CategoryScale::generate_ticks(self : CategoryScale) -> Array[String] {
  self.categories
}
