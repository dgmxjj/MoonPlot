///|
/// A data-space annotation rendered through the same scale and backend as a series.
pub(all) struct Annotation {
  text : String
  x : Double
  y : Double
  color : @color.Color
  size : Double
}

///|
pub fn Annotation::new(text : String, x : Double, y : Double) -> Annotation {
  { text, x, y, color: @color.black, size: 12.0 }
}

///|
pub fn Annotation::set_color(
  self : Annotation,
  color : @color.Color,
) -> Annotation {
  { ..self, color, }
}

///|
pub fn Annotation::set_size(self : Annotation, size : Double) -> Annotation {
  { ..self, size: if size > 0.0 { size } else { 1.0 } }
}

///|
pub fn Annotation::text(self : Annotation) -> String {
  self.text
}

///|
pub(all) struct AnnotationLayer {
  annotations : Array[Annotation]
}

///|
pub fn AnnotationLayer::new() -> AnnotationLayer {
  { annotations: [] }
}

///|
pub fn AnnotationLayer::add(
  self : AnnotationLayer,
  annotation : Annotation,
) -> AnnotationLayer {
  self.annotations.push(annotation)
  self
}

///|
pub fn AnnotationLayer::count(self : AnnotationLayer) -> Int {
  self.annotations.length()
}

///|
pub fn[B : @backend.Backend, SX : @coord.Scale, SY : @coord.Scale] AnnotationLayer::draw(
  self : AnnotationLayer,
  backend : B,
  scale_x : SX,
  scale_y : SY,
) -> Unit {
  for annotation in self.annotations {
    let font : @backend.Font = {
      family: "sans-serif",
      size: annotation.size,
      weight: "normal",
    }
    backend.draw_text(
      annotation.text,
      scale_x.map(annotation.x) + 5.0,
      scale_y.map(annotation.y),
      font,
      annotation.color,
      @backend.TextAlign::Left,
      @backend.TextBaseline::Middle,
    )
  }
}
