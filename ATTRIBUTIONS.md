# 署名与致谢

本配置方案基于以下开源项目和社区成果构建。感谢每一位贡献者。

## 核心基础设施

| 项目 | 作者/团队 | 仓库 | 许可证 |
|------|----------|------|--------|
| **Claude Code** | Anthropic | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Proprietary |
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
| **mattpocock/skills** | Matt Pocock | [github.com/mattpocock/skills](https://github.com/mattpocock/skills) | 工程化技能包（Issue 跟踪、Triage、TDD、PRD 等） |

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

以下 Agent 的概念和检查清单借鉴了社区最佳实践：

- **senior-dev**：借鉴了 Google SWE 最佳实践、PSR 编码标准
- **code-reviewer**：OWASP Top 10、CWE、Google Code Review Guidelines
- **security-reviewer**：OWASP Top 10 (2021)、CWE Top 25
- **tdd-guide**：Kent Beck's Test-Driven Development、AAA Pattern
- **build-error-resolver**：系统化排错方法论

## 规则与最佳实践

规则文件中的内容综合自：
- Clean Code (Robert C. Martin)
- The Pragmatic Programmer (Hunt & Thomas)
- OWASP Secure Coding Practices
- Google Engineering Practices
- 社区公认的编码规范（KISS、DRY、YAGNI、SOLID）

---

**如果有遗漏或错误归属，请提 Issue 或 PR 修正。**
