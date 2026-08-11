# MoonPlot 🌔📊

MoonPlot 是一个完全由 MoonBit 编写的声明式数据图表生成与可视化库。它把比例尺、图表布局、数据系列和渲染后端拆开，让同一份图表声明可以输出 SVG，也可以生成 Canvas 2D 命令。

[![MoonBit CI](https://github.com/dgmxjj/MoonPlot/actions/workflows/test.yml/badge.svg)](https://github.com/dgmxjj/MoonPlot/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![MoonBit OSC2026](https://img.shields.io/badge/MoonBit-OSC2026-blue.svg)](https://moonbitlang.github.io/OSC2026/)

## 特性

- 后端无关的 `Backend` trait：内置 `SVGBackend` 和 Canvas 2D 命令后端。
- 折线图、散点图和柱状图数据系列，支持线性、对数和分类比例尺。
- 支持正负分离堆叠柱状图、数据范围估计、注释层和稳定分类调色板。
- `ChartBuilder` + `ChartLayout` 声明式布局：标题、图例、网格和绘图区边界由同一个布局对象计算。
- 图例宽度自适应，极小画布也保持有效的绘图区；网格可以按图表声明关闭。
- 纯 MoonBit 实现，带有边界测试、可执行示例和三平台 CI。

## 安装

### 从 Mooncakes 安装

```bash
moon add dgmxjj/moonplot@0.4.0
```

包发布后，按模块包路径导入，例如 `dgmxjj/moonplot/src/chart`、`dgmxjj/moonplot/src/series` 和 `dgmxjj/moonplot/src/backend`。如果要使用仓库中的示例或参与开发，请直接克隆源码。

### 从源码运行

请先安装 MoonBit 工具链。项目以 MoonBit 0.10.3 作为验收基线，建议使用官方安装器获取与 CI 一致的版本；验收 CI 会在 Linux、macOS 和 Windows 上安装工具链及 native 编译依赖。

```bash
git clone https://github.com/dgmxjj/MoonPlot.git
cd MoonPlot
moon update
moon version --all
```

## 可执行示例

两个示例都是可直接运行的 MoonBit executable package，会把 SVG 写到标准输出：

```bash
moon run examples/basic_line > line_chart.svg
moon run examples/basic_bar > bar_chart.svg
moon run examples/benchmark_summary > iris-benchmark.svg
```

PowerShell 用户可以显式指定 UTF-8 输出：

```powershell
moon run examples/basic_line | Set-Content -Encoding utf8 line_chart.svg
moon run examples/basic_bar | Set-Content -Encoding utf8 bar_chart.svg
```

也可以使用 Make：

```bash
make examples
```

`line_chart.svg` 应包含折线 `<line>`、坐标轴、网格和图例；`bar_chart.svg` 应包含柱形 `<rect>`、分类刻度和图例。生成的本地 SVG 不纳入版本控制。

基准示例使用仓库内的 UCI Iris 18 行数据子集，执行完整的 CSV 解析、统计摘要、比例尺和 SVG 渲染链路。数据来源、CC BY 4.0 署名和预期结果见 [`docs/BENCHMARKS.md`](docs/BENCHMARKS.md)。

## 最小使用方式

下面的调用顺序展示了真实 API：先声明后端和图表，再从布局对象读取绘图区，最后绘制网格、坐标轴和数据系列。

```moonbit
let backend = @backend.SVGBackend::new(800.0, 600.0)
let chart = @chart.ChartBuilder::new(backend)
  .set_title("Benchmark")
  .set_show_grid(true)
  .add_legend_item("throughput", @color.blue, "line")
let layout = chart.layout()
let (x_min, y_min, x_max, y_max) = layout.plot_bounds()
let scale_x = @coord.LinearScale::new(0.0, 10.0, x_min, x_max)
let scale_y = @coord.LinearScale::new(0.0, 100.0, y_max, y_min)
chart.draw_title()
chart.draw_legend()
chart.draw_grid(scale_x, scale_y, 6, 6)
@series.LineSeries::new([(0.0, 10.0), (5.0, 55.0), (10.0, 90.0)])
  .set_color(@color.blue)
  .draw(backend, scale_x, scale_y)
println(backend.to_string())
```

完整的 API 说明见 [`docs/API.md`](docs/API.md)，布局设计见 [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)。

## 项目结构

```text
src/backend/   Backend trait、SVGBackend、CanvasBackend
src/chart/     ChartBuilder、ChartLayout、标题、图例、网格和坐标轴
src/color/     Color、调色板和颜色混合
src/coord/     LinearScale、LogarithmicScale、CategoryScale
src/series/    LineSeries、ScatterSeries、BarSeries 与数据范围辅助
src/data/      纯字符串 CSV 表格解析与数值列转换
src/stats/     描述性统计、分位数、分箱、窗口聚合和相关系数
src/layout/    多面板网格与图例换行布局
examples/      可执行 SVG 示例与版本化基准数据
docs/          API、架构、基准、开发记录和参考范围
```

每个子目录都是独立的 MoonBit package；公开 API 的 `.mbti` 接口文件由 `moon info` 生成并纳入版本控制。

## 验证与 CI

本地常用检查命令：

```bash
moon check --target all --deny-warn
moon build --target all --deny-warn
moon test --target all --deny-warn
moon fmt --check
moon info
```

GitHub Actions 使用官方 MoonBit 安装器，在 `ubuntu-latest`、`macos-latest` 和 `windows-latest` 上执行同样的全目标检查、构建、测试、格式检查和接口漂移检查。Windows native 构建使用 MSYS2 UCRT64 GCC；本机没有 C 编译器时，可先运行对应平台的 CI 或安装 MSYS2。

### 边界行为

空数据系列不输出图形；空 CSV 返回明确错误；CSV 列数不一致报告行号；非法数字列报告数据行号；常数比例尺回退到有效起点；负值柱状图以零线为基线；负半径、负柱宽、非法窗口和极小画布会被安全钳制；SVG/Canvas 文本会转义 XML/JavaScript 特殊字符。

## 当前范围与非目标

当前版本覆盖 SVG 离线输出和 Canvas 2D 命令生成；Canvas 后端不直接持有浏览器上下文，调用方负责把 `to_js_code("ctx")` 注入页面。当前不包含动画、交互式坐标轴、自动文本测量和完整 Web UI 组件。布局模块提供稳定的绘图区/图例边界，后续可以在不改变数据系列 API 的情况下扩展这些能力。

## 参考与致谢

- [MoonBit](https://www.moonbitlang.com/)：语言与工具链。
- [Plotters](https://github.com/plotters-rs/plotters)：后端解耦、比例尺和图表组件组织方式的公开参考，Apache-2.0。
- [MDN Canvas 2D API](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D)：Canvas 命令语义参考。
- [W3C SVG 2](https://www.w3.org/TR/SVG2/)：SVG 元素和文本转义范围参考。
- [UCI Iris](https://archive.ics.uci.edu/dataset/53/iris)：基准数据子集来源与 CC BY 4.0 署名信息。

MoonPlot 未复制上述项目的源代码；参考范围仅限公开 API 设计和图形渲染概念。项目自身使用 MIT License，基准数据保留独立的 CC BY 4.0 署名要求，详见 [`LICENSE`](LICENSE) 和 [`docs/REFERENCES.md`](docs/REFERENCES.md)。

## 项目链接

- GitHub：<https://github.com/dgmxjj/MoonPlot>
- GitLink：<https://gitlink.org.cn/Dgmxjj/MoonPlot>
- Mooncakes：<https://mooncakes.io/>

## 许可证

Copyright (c) 2026 Dgmxjj。MoonPlot 使用 [MIT License](LICENSE) 发布。
