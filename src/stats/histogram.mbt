///|
pub(all) struct HistogramBin {
  lower : Double
  upper : Double
  count : Int
}

///|
pub fn NumericSeries::histogram(
  self : NumericSeries,
  requested_bins : Int,
) -> Array[HistogramBin] {
  let bins : Array[HistogramBin] = []
  if self.data.length() == 0 || requested_bins <= 0 {
    return bins
  }
  let count = requested_bins
  let low = self.min()
  let high = self.max()
  if low == high {
    bins.push({ lower: low, upper: high, count: self.data.length() })
    return bins
  }
  let width = (high - low) / count.to_double()
  for i = 0; i < count; i = i + 1 {
    bins.push({
      lower: low + width * i.to_double(),
      upper: if i == count - 1 {
        high
      } else {
        low + width * (i + 1).to_double()
      },
      count: 0,
    })
  }
  for value in self.data {
    let raw_index = ((value - low) / width).to_int()
    let index = if raw_index < 0 {
      0
    } else if raw_index >= count {
      count - 1
    } else {
      raw_index
    }
    let current = bins[index]
    bins[index] = { ..current, count: current.count + 1 }
  }
  bins
}
