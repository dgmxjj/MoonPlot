# MoonPlot API Reference

模块导入路径以 `dgmxjj/moonplot/src/` 开头。公开接口文件可以用 `moon info` 重新生成。

## Backend

`@backend.Backend` 是后端无关的绘图接口，提供 `draw_line`、`draw_rect`、`draw_circle`、`draw_polygon` 和 `draw_text`。图表和数据系列只依赖这个 trait，不依赖具体输出格式。

- `@backend.SVGBackend::new(width, height)` 创建 SVG 后端。
- `backend.to_string()` 返回完整 SVG 文档。
- `@backend.CanvasBackend::new(width, height)` 记录 Canvas 2D 命令。
- `backend.to_js_code("ctx")` 生成可注入浏览器上下文的 JavaScript 命令。

## ChartBuilder and ChartLayout

`ChartBuilder[B]` 保存后端、标题、网格开关、内边距和图例声明：

- `set_title(title)`
- `set_padding(left, right, top, bottom)`
- `set_show_grid(show_grid)`
- `add_legend_item(name, color, style)`，其中 `style` 可为 `line`、`bar` 或 `scatter`
- `layout()` 返回 `ChartLayout`

`ChartLayout` 是布局计算结果：

- `plot_bounds()` 返回 `(x_min, y_min, x_max, y_max)`。
- `legend_origin()` 返回图例绘制起点。

`layout()` 会依据最长图例文本扩展右侧空间，并保证极小画布的绘图区仍有正宽高。`draw_title`、`draw_legend`、`draw_grid` 和两个坐标轴绘制方法都使用同一套边界。

## Scales

`@coord.Scale` 统一 `map` 和 `generate_ticks`：

- `LinearScale::new(domain_min, domain_max, range_min, range_max)`
- `LogarithmicScale::new(domain_min, domain_max, range_min, range_max, base?)`
- `CategoryScale::new(categories, range_min, range_max)`

线性和对数比例尺适用于连续数值；分类比例尺把每个类别映射到区间中心，未知类别回退到 `range_min`。

## Series

- `LineSeries::new(points).set_color(color).set_width(width).draw(...)`
- `ScatterSeries::new(points).draw(...)`，支持 `Circle`、`Square`、`Cross`。
- `BarSeries::new((category, value) data).draw(...)`，柱子同时正确处理正值、零值和负值。

数据系列只接收比例尺和 `Backend`，因此同一系列可以渲染到 SVG 或 Canvas 后端。

## 版本与兼容性

当前模块版本为 `0.3.0`，目标是 MoonBit 0.10.3 兼容的 `moon.mod` / `moon.pkg` 配置。具体工具链版本可能继续更新；提交前请运行 README 中的全目标验证命令。
