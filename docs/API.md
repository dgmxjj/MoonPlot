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

- `LineSeries::new(points).set_color(color).set_width(width).set_smooth(bool).bounds()`
- `ScatterSeries::new(points).set_color(color).set_radius(radius).set_style(style).bounds()`，支持 `Circle`、`Square`、`Cross`。
- `BarSeries::new((category, value) data).set_color(color).set_bar_width(width).bounds()`，柱子同时正确处理正值、零值和负值。
- `StackedBarSeries::new((category, values) data).draw(...)` 将正负段分别从零线向外堆叠。
- `AreaSeries::new(points).set_baseline(value).draw(...)` 绘制带基线的连续面积区域。
- `RangeSeries::new((x, low, high) data).set_opacity(value).draw(...)` 绘制监控阈值或置信区间带。
- `BoxPlotSeries::new(position, values).draw(...)` 绘制四分位盒、中央値和上下须。
- `HeatmapSeries::new(matrix).set_domain(low, high).draw(...)` 将二维数值矩阵绘制为稳定的颜色单元格。

数据系列只接收比例尺和 `Backend`，因此同一系列可以渲染到 SVG 或 Canvas 后端。

## Data and statistics

`@data.CsvTable::parse(text)` 是不依赖文件系统的 CSV 入口，支持引号字段、逗号、空字段和 CRLF。结果为 `Result[CsvTable, CsvError]`；`numeric_column(name)` 会把列转换为 `Array[Double]`，非法数字报告数据行号。

`CsvTable::profile()` 返回每列的类型、缺失数、基数、数值范围和分类频数；`group_numeric(group, value)` 提供稳定的分组统计；`pivot_numeric(row, column, value)` 生成可直接交给热力图的二维矩阵。缺失单元返回零，非法数字保留原始数据行号。

`@stats.NumericSeries` 提供：

- `summary()`：样本数、最小值、最大值、均值、中位数、方差和标准差；
- `quantile()`、`histogram()`、`normalize()`、`clip()`、`moving_average()`、`correlation()`；
- `median_absolute_deviation()`、`outlier_indices()`、`rolling_min()`、`rolling_max()` 和 `resample()`。
- `linear_regression()`、`LinearRegression::predict()`、`residuals()`、`mean_squared_error()`；
- `z_scores()`、`standard_error()` 和 `autocorrelation(lag)`，用于监控和趋势诊断。

所有统计方法对空序列、常数序列、非法窗口、非法分箱数和目标样本数做确定性处理，适合在渲染前作为数据清洗与降采样层。

## Responsive layout and colors

- `@layout.PanelGrid` 计算带边距/间距的行列面板，`panel(index)` 以行优先顺序返回 `Rect`；`columns_for_width()` 可用于响应式仪表盘。
- `@layout.LegendLayout` 支持垂直或水平图例流，水平流会在最大宽度处换行，避免图例覆盖绘图区。
- `@color.palette(count)` 生成稳定的分类色板；`gradient()`、`Color::with_alpha()`、`luminance()` 和 `contrast_ratio()` 用于主题与可读性检查。

## 版本与兼容性

当前模块版本为 `0.5.0`，目标是 MoonBit 0.10.3 兼容的 `moon.mod` / `moon.pkg` 配置。新增数据、统计、系列与布局包保持独立导入；提交前请运行 README 中的全目标验证命令。
