# 可复现基准数据

MoonPlot 的基准同时验证“数据解析 → 数值摘要 → 比例尺 → SVG 输出”这条完整路径。基准数据都放在 `examples/data/`，不依赖网络服务和本地数据库。

## UCI Iris 子集

`examples/data/iris_measurements.csv` 是 UCI Iris 数据集的 18 行可审计子集，保留四个连续测量字段和物种标签。原始数据由 R. A. Fisher 提供，UCI 页面给出 DOI `10.24432/C56C76`，数据采用 CC BY 4.0；本仓库只保留用于示例和回归验证的子集，并在 `docs/REFERENCES.md` 中保留署名与许可证说明。

运行：

```bash
moon run examples/benchmark_summary > iris-benchmark.svg
```

预期输出：

- SVG 根节点尺寸为 `720 × 440`；
- 标题包含 `UCI Iris petal width (n=18)`；
- 图例包含均值；
- 输出同时包含坐标轴、网格和折线元素；
- `petal_width` 的样本数为 18，最小值为 0.2，最大值为 2.5。

## Throughput/latency 工程夹具

`examples/data/throughput_latency.csv` 是 MoonPlot 工程回归使用的确定性性能趋势夹具，字段为样本序号、吞吐量和毫秒延迟。它不宣称代表某个生产系统；用途是验证正相关趋势、分位数、滑动平均、直方图和图例布局在稳定输入上的结果。

## 统计结果复核

```bash
moon test src/data --target wasm --deny-warn
moon test src/stats --target wasm --deny-warn
moon run examples/benchmark_summary --target wasm > iris-benchmark.svg
```

异常输入也纳入测试：空 CSV、引号字段、逗号字段、列数不一致、非法数字、空序列、常数序列、非法分箱数、非正窗口、负柱状值、退化比例尺、极小画布和特殊字符转义。

## Advanced report

```bash
moon run examples/advanced_report --target wasm > advanced-report.svg
moon test examples/advanced_report/report --target wasm --deny-warn
```

该报告固定输出 4 行、3 列、两个区域分组和 `slope=-0.18` 的回归结果，并渲染 4 个热力图单元格。它同时验证表格剖析、分组聚合、线性回归、颜色插值和 SVG 后端；报告包的测试不依赖本地文件系统。

## 数据许可

Iris 子集遵循原数据的 CC BY 4.0 署名要求；MoonPlot 源码仍以根目录 MIT License 发布。数据许可不改变源码许可证，使用者应同时遵守对应数据集的署名要求。
