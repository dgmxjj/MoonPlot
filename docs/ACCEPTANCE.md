# 组委会驳回意见逐项复核

本文把组委会反馈中的技术项映射到仓库证据，便于在干净环境中复核。截图中的通知属于本项目的验收意见；比赛日期和通知渠道不作为代码、CI 或许可证配置写入项目。

## 复核矩阵

| 反馈项 | 仓库证据 | 可复核命令 / 结果 |
| --- | --- | --- |
| 三平台 CI | `.github/workflows/test.yml` 使用 `ubuntu-latest`、`macos-latest`、`windows-latest` 矩阵，并安装各平台 native 依赖 | `moon check/build/test --target all --deny-warn`；CI 对三个矩阵任务分别执行 |
| 补上 `moon build` | `.github/workflows/test.yml` 的 `Build all targets` 步骤 | `moon build --target all --deny-warn` |
| README 安装、运行、可执行示例 | `README.md` 的安装、源码运行、`basic_line`、`basic_bar`、`benchmark_summary`、`advanced_report` 章节 | 按 README 命令生成 SVG；示例包均使用 `options(is_main: true)` |
| Bar / Scatter 测试 | `src/series/series_test.mbt` 覆盖零值、负值、样式、空输入、配置和范围 | `moon test --target all --deny-warn` |
| Canvas 测试 | `src/backend/canvas_test.mbt` 覆盖命令生成、文本转义、空多边形、清空与命令计数 | 同上，并检查 `to_js_code` 输出 |
| 边界条件 | `src/coord/scale_test.mbt`、`src/chart/svg_test.mbt`、`src/data/*_test.mbt`、`src/series/*_test.mbt`、`src/stats/*_test.mbt` | 覆盖空数据、负值、常数/倒置范围、非法数字、缺失字段、锯齿矩阵、极小画布和非法参数 |
| 声明式 API 与布局防冲突 | `src/chart`、`src/layout`；布局统一返回 `plot_bounds`，`Dashboard` 使用 `PanelGrid` 计算面板边界 | `chart_layout_separates_plot_and_long_legend`、`chart_layout_keeps_a_positive_plot_for_small_canvas`、Dashboard 测试 |
| Plotters 链接、许可证、参考范围 | `README.md`、`docs/REFERENCES.md`、`docs/ARCHITECTURE.md` | 明确 Plotters 仅为公开设计参考；没有复制源码；项目源码为 MIT，UCI 子集单独按 CC BY 4.0 署名 |
| 移除平台凭据 | 仓库不保存账号、密码、令牌、CI secret、临时平台截图或本地凭据文件 | 提交前执行敏感字段扫描；远程 URL 不嵌入凭据 |

## 当前可复现结果

在 MoonBit 0.10.3 环境中，以下命令已经通过：

```bash
moon fmt --check src examples
moon check --target all --deny-warn
moon build --target wasm --deny-warn
moon test --target wasm --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon build --target js --deny-warn
moon test --target js --deny-warn
moon run examples/benchmark_summary --target wasm
moon run examples/advanced_report --target wasm
```

远程 CI 还执行 native 构建和测试。最近一次作者身份清理后的 GitHub 三平台运行结果为成功；GitHub 和 GitLink 的默认分支均为 `main`，提交历史保持仓库创建者 `Dgmxjj` 的单一作者/提交者身份。

## 范围与诚实性说明

MoonPlot 当前提供 SVG 离线输出和 Canvas 2D 命令生成，不宣称提供浏览器运行时、动画、交互式坐标轴或完整 Web UI。源码规模统计排除 `_build`、`.mbti` 和其他生成物；测试和覆盖率结果按真实命令记录，不用构建产物虚增工程量。
