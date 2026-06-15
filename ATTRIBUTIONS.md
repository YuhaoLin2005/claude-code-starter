# 署名与致谢

本配置方案基于以下开源项目和社区成果构建。感谢每一位贡献者。

## 核心基础设施

| 项目 | 作者/团队 | 仓库 | 许可证 |
|------|----------|------|--------|
| **Claude Code** | Anthropic | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Proprietary |
| **Model Context Protocol (MCP)** | Anthropic | [modelcontextprotocol](https://github.com/modelcontextprotocol) | MIT |
| **DeepSeek API** | 深度求索 | [platform.deepseek.com](https://platform.deepseek.com) | — |

## Token 优化

| 项目 | 作者 | 仓库 | 说明 |
|------|------|------|------|
| **RTK (Rust Token Killer)** | @reachingforthejack | [github.com/reachingforthejack/rtk](https://github.com/reachingforthejack/rtk) | CLI 代理，60-90% Bash token 节省 |

## Claude Code 插件

| 插件 | 来源 | 说明 |
|------|------|------|
| frontend-design | @claude-plugins-official | 前端设计技能 |
| feature-dev | @claude-plugins-official | 功能开发子代理 |
| commit-commands | @claude-plugins-official | 提交命令 |
| code-modernization | @claude-plugins-official | 代码现代化 |
| code-review | @claude-plugins-official | 代码审查 |
| code-simplifier | @claude-plugins-official | 代码简化 |
| hookify | @claude-plugins-official | Hook 规则生成 |
| claude-md-management | @claude-plugins-official | CLAUDE.md 管理 |

## Agent 技能

| 项目 | 作者 | 仓库 | 说明 |
|------|------|------|------|
| **mattpocock/skills** | Matt Pocock | [github.com/mattpocock/skills](https://github.com/mattpocock/skills) | 工程化技能包，本配置使用了以下子技能： |
| ├ grill-with-docs | Matt Pocock | 同上 | 领域文档生成器 — 自动沉淀项目知识 |
| ├ triage | Matt Pocock | 同上 | 问题分类器 — 自动打标签、判优先级 |
| ├ tdd | Matt Pocock | 同上 | 测试驱动开发向导 |
| ├ to-issues | Matt Pocock | 同上 | 需求拆解器 — PRD → 小任务 |
| ├ diagnose | Matt Pocock | 同上 | 问题诊断器 — 深入分析根因 |
| ├ zoom-out | Matt Pocock | 同上 | 架构视角切换 — 全局审视 |
| └ prototype | Matt Pocock | 同上 | 原型快速构建 — 验证可行性 |

## MCP 服务器

| 服务 | 包名 | 仓库 |
|------|------|------|
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) |
| **Playwright** | `@playwright/mcp` | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) |
| **GitHub** | GitHub Copilot MCP | api.githubcopilot.com |
| **PostgreSQL** | `@modelcontextprotocol/server-postgres` | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) |
| **Context7** | `@upstash/context7-mcp` | [upstash/context7](https://github.com/upstash/context7) |
| **DuckDuckGo** | `duckduckgo-mcp-server` | NPM |
| **Vision** | `mcp-vision` | [hahahahanb/mcp-vision](https://github.com/hahahahanb/mcp-vision) |
| **Parallel Search** | Parallel AI Search | [search.parallel.ai](https://search.parallel.ai) |
| **Squish Memory** | `squish-memory` | NPM（本地 SQLite 持久化记忆） |

## Vision 后端

| 服务 | 提供方 | 链接 |
|------|--------|------|
| **DashScope qwen-vl-max** | 阿里云 | [dashscope.aliyun.com](https://dashscope.aliyun.com) |

## Python / Node 工具链

| 工具 | 作者/团队 | 链接 |
|------|----------|------|
| **uv** | Astral | [astral.sh](https://astral.sh) |
| **Node.js** | OpenJS Foundation | [nodejs.org](https://nodejs.org) |
| **npx** | npm Inc. | [npmjs.com](https://www.npmjs.com) |

## Agent 设计灵感

以下 Agent 的概念和检查清单借鉴了社区最佳实践，感谢这些知识源头：

| Agent | 灵感来源 |
|-------|---------|
| **senior-dev** | Google SWE Best Practices、PSR 编码标准、Production-grade code review 方法论 |
| **code-reviewer** | OWASP Top 10 (2021)、CWE Top 25、Google Code Review Guidelines |
| **security-reviewer** | OWASP Top 10、CWE Top 25、SANS Secure Coding |
| **tdd-guide** | Kent Beck's *Test-Driven Development: By Example*、AAA Pattern (Arrange-Act-Assert) |
| **planner** | *The Pragmatic Programmer* (Hunt & Thomas)、软件架构方法论 |
| **architect** | C4 Model (Simon Brown)、ADR (Architecture Decision Records)、SOLID 原则 |
| **build-error-resolver** | 系统化排错方法论、Unix 哲学（do one thing well） |
| **rust-reviewer** | *The Rust Programming Language*、Rust API Guidelines、Clippy lints |
| **doc-updater** | *Docs as Code* 理念、Keep a Changelog 规范 |

## 规则与最佳实践

规则文件中的内容综合自：
- Clean Code (Robert C. Martin)
- The Pragmatic Programmer (Hunt & Thomas)
- OWASP Secure Coding Practices
- Google Engineering Practices
- 社区公认的编码规范（KISS、DRY、YAGNI、SOLID）

---

**如果有遗漏或错误归属，请提 Issue 或 PR 修正。**
