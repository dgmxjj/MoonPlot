# References and Scope

MoonPlot is an independent MoonBit implementation. The following links are design references, not runtime dependencies:

| Reference | Used for | License / scope |
| --- | --- | --- |
| [Plotters](https://github.com/plotters-rs/plotters) | Backend separation, chart components, scale-oriented rendering | Apache-2.0; no source copied |
| [MDN Canvas 2D API](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D) | Canvas command names and text alignment semantics | Public web API reference |
| [W3C SVG 2](https://www.w3.org/TR/SVG2/) | SVG element and text serialization semantics | Web standard reference |
| [MoonBit documentation](https://docs.moonbitlang.com/) | Module, package, formatter and test conventions | Language/toolchain documentation |

The project does not depend on Plotters, a browser runtime, or a JavaScript library. The implementation is distributed under the MIT License in the repository root.
