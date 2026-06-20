pub trait Scale {
  map(self : Self, value: Double) -> Double
  generate_ticks(self : Self, count: Int) -> Array[Double]
}

pub struct LinearScale {
  domain_min: Double
  domain_max: Double
  range_min: Double
  range_max: Double
}

pub fn LinearScale::new(dmin: Double, dmax: Double, rmin: Double, rmax: Double) -> LinearScale {
  { domain_min: dmin, domain_max: dmax, range_min: rmin, range_max: rmax }
}

pub fn LinearScale::map(self : LinearScale, value : Double) -> Double {
  if self.domain_max == self.domain_min {
    return self.range_min
  }
  let ratio = (value - self.domain_min) / (self.domain_max - self.domain_min)
  self.range_min + ratio * (self.range_max - self.range_min)
}

pub fn LinearScale::generate_ticks(self : LinearScale, count : Int) -> Array[Double] {
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

impl Scale for LinearScale with map(self, value) {
  self.map(value)
}

impl Scale for LinearScale with generate_ticks(self, count) {
  self.generate_ticks(count)
}
