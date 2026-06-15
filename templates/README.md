# 场景模板

本目录包含三套项目模板，按技术场景分类。每套模板提供对应的 `CLAUDE.md` 片段和推荐规则文件子集。

## 模板列表

| 目录 | 适用场景 | 核心技术栈 | 重点规则 |
|------|---------|-----------|---------|
| [`frontend/`](frontend/) | 前端项目 | React, Vue, Next.js, TypeScript | 组件规范, XSS防护, 性能优化 |
| [`backend/`](backend/) | 后端工程 | Go, Python, Java, Node.js | API规范, SQL安全, 错误处理, Repository模式 |
| [`math-alg/`](math-alg/) | 算法 & 数学 | Python, NumPy, PyTorch, SciPy | 数值计算, 数据处理, 模型训练, 可视化 |

## 使用方法

1. 根据你的项目类型选择对应目录
2. 将模板中的 `CLAUDE.md` 片段合并到你项目的 `CLAUDE.md`
3. 将推荐规则文件复制到项目 `.claude/rules/`
4. 根据项目实际情况调整

## 其他模板文件

本目录还包含全局配置文件模板（不分场景）：
- `mcp.json.example` — MCP 服务器配置模板（需改路径）
- `settings.local.json.example` — 本地设置模板（一般不需要）
