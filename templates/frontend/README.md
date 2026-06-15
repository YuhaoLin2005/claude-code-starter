# 前端项目模板

适用于：React / Vue / Next.js / TypeScript 前端项目。

## 使用方法

将此模板的 `CLAUDE.md` 片段合并到你项目的 `CLAUDE.md` 中（或直接复制使用）。

## 模板特点

- 组件化开发规范
- TypeScript 严格模式提示
- 前端性能优化约束（避免不必要的重渲染、大依赖引入警告）
- UI/UX 审查要点
- 前端安全规则（XSS、CSRF）

## 包含规则

复制以下规则文件到项目 `.claude/rules/`：
- `code-quality.md`（全栈通用）
- `security.md`（含前端 XSS 专项）
- `testing.md`（含组件测试）
- `performance.md`（前端性能专项）

## CLAUDE.md 模板

```markdown
# 项目概述

这是一个 [React/Vue/Next.js] 前端项目，使用 TypeScript 开发。

## 技术栈
- 框架：[React 18+ / Vue 3 / Next.js 14+]
- 语言：TypeScript (strict mode)
- 样式：[Tailwind CSS / CSS Modules / styled-components]
- 状态管理：[Zustand / Pinia / Redux Toolkit]
- 测试：[Vitest / Jest] + [React Testing Library / Vue Test Utils]

## 代码规范
- 组件使用函数式声明，避免 class component
- Props 使用 interface 定义，禁止 inline type
- 一个文件只导出一个组件（除非是 compound components）
- 避免超过 200 行的组件，拆分为子组件或 hooks

## 安全
- 所有用户输入使用 DOMPurify 消毒
- 避免 dangerouslySetInnerHTML / v-html
- API 请求携带 CSRF token

## 性能
- 大列表使用虚拟滚动（react-window / vue-virtual-scroller）
- 图片使用懒加载 + WebP 格式
- 避免在渲染路径中进行复杂计算
```

> 📌 完整规则文件见仓库根目录 `.claude/rules/`。
