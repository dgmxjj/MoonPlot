# 开发与验收记录

## 工程决策

- 用 `Backend` trait 隔离 SVG 和 Canvas，系列只依赖绘图原语，便于增加后端。
- 用 `ChartLayout` 和 `PanelGrid` 集中计算绘图区、图例与多面板边界，避免每个系列自行猜测坐标。
- 把 CSV 解析设计为纯字符串 API，不绑定文件系统，因此 WASM、JS、native 三类目标拥有同一行为。
- 把统计处理做成独立 `stats` package，图表 API 只消费点、分类值和比例尺，避免渲染器承担数据清洗职责。
- 把表格剖析、分组聚合和二维透视留在 `data` package；回归和序列诊断留在 `stats` package；面积、区间、箱线和热力图只依赖 `Backend`/`Scale`。
- executable 示例只负责入口，复杂报告流程放在独立库包中，以避免 MoonBit 主包黑盒测试警告并允许直接复用。

## 质量流程

每个新增行为先写黑盒测试，使用 MoonBit 0.10.3 基线运行失败，再实现最小逻辑并运行格式、检查、构建和测试。提交前还运行 `moon info`，确认公开 `.mbti` 没有未审查的接口漂移。

## 工具与参考

本项目使用 MoonBit 官方工具链、Mooncakes 包管理器和 GitHub Actions。实现参考 Plotters 的后端解耦思想、MDN Canvas 2D 命令语义和 W3C SVG 文本转义边界；没有复制这些项目的源代码。参考范围和许可证见 [`REFERENCES.md`](REFERENCES.md)。

## AI 辅助与人工审查

AI 工具仅用于检索公开规范、生成测试候选、检查编译诊断和整理文档；API 边界、错误行为、许可证、数据署名、提交身份和最终命令结果由项目维护者人工审查。仓库不保存账号、密码、令牌、平台内部凭据或临时平台截图。

## 发布前清单

- `moon fmt --check`
- `moon check --target all --deny-warn`
- `moon build --target all --deny-warn`
- `moon test --target all --deny-warn`
- `moon info`
- `git status --short`
- `git shortlog -sne HEAD`
