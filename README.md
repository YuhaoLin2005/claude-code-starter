# Claude Code 开箱即用配置：DeepSeek + Windows 完整方案

> A battle-tested Claude Code configuration for DeepSeek API on Windows. 9 MCP services, 9 custom agents, 6 quality rules, and RTK token optimization — everything you need to go from zero to productive in 15 minutes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](#)
[![Model: DeepSeek](https://img.shields.io/badge/Model-DeepSeek_v4_Pro-green.svg)](#)
[![RTK: 55% Savings](https://img.shields.io/badge/RTK-55%25_Token_Savings-purple.svg)](#)

---

## 这是什么

Claude Code 很强大，但从零配到好用中间有太多细碎的事情——MCP 服务一个个找包、权限弹窗点到手软、子 Agent 模型不对导致输出质量差、命令动不动就占满 token……

这个仓库把折腾过程中验证过的配置整理好了。**不追求极致，只追求"用起来舒服"。**

### 实际效果

```bash
$ rtk gain --history

RTK Token Savings (Global Scope)
════════════════════════════════════════════════════════════
Total commands:    165
Input tokens:      38.1K
Output tokens:     17.3K
Tokens saved:      20.9K (54.7%)
Efficiency meter:  █████████████░░░░░░░░░░░ 54.7%
```

```bash
$ ls .claude/agents/

architect.md    code-reviewer.md    planner.md        security-reviewer.md
build-error-resolver.md  doc-updater.md  rust-reviewer.md  senior-dev.md  tdd-guide.md

$ ls .claude/rules/

code-quality.md  patterns.md  performance.md  security.md  testing.md  workflow.md
```

## 里面有什么

| 类别 | 数量 | 包含内容 |
|------|:--:|------|
| 🧩 **MCP 服务** | 9 | 文件操作 · 浏览器自动化 · GitHub · PostgreSQL · 文档搜索(Context7) · 搜索(DuckDuckGo) · 图片识别(Vision) · LLM搜索(Parallel) · 持久化记忆(Squish) |
| 🤖 **自定义 Agent** | 9 | 代码审查 · 安全检查 · TDD 向导 · 架构设计 · 构建排错 · 代码简化 · 文档更新 · Rust 审查 · 高级实现 |
| 📋 **规则文件** | 6 | 代码质量 · 安全 · 测试 · 工作流(含自动备份) · 性能 · 设计模式 |
| ⚡ **RTK 集成** | — | Shell 命令自动精简，实测节省 55% token |
| 🧠 **中文智能提醒** | — | 在合适场景用中文主动提示可用技能 |
| 🪟 **Windows 友好** | — | MCP 路径、RTK hook、Python 环境都踩过坑了 |

## 快速开始

```bash
# 1. 注册 DeepSeek 获取 API Key → https://platform.deepseek.com
# 2. 克隆仓库
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter

# 3. 复制配置
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json
cp templates/settings.local.json.example ~/.claude/settings.local.json

# 4. 编辑 ~/.mcp.json，把文件路径改成你自己的

# 5. 设置环境变量
#    Windows: setx ANTHROPIC_API_KEY "sk-your-deepseek-key"
#    Mac/Linux: export ANTHROPIC_API_KEY="sk-your-deepseek-key"

# 6. 重启 Claude Code
```

📖 **[详细设置指南](SETUP.md)** · ❓ [提 Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues)

---

## 踩坑笔记

折腾过程中踩过的坑，可能会帮你省一些时间：

- **子 Agent 输出质量差**：默认用了 flash 模型，设 `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro` 后正常
- **缓存命中率低**：加 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 从 50% 提升到 90%+
- **Windows MCP 路径**：filesystem 服务器的路径要写双反斜杠 `C:\\Users\\...`
- **RTK 安装注意**：有个重名包 (Rust Type Kit)，别装错了
- **Vision 图片识别**：DeepSeek 不支持图片，搭 mcp-vision + DashScope 桥接
- **PyTorch GPU**：QGIS 自带 Python 的 DLL 会冲突 (c10.dll 1114)，装独立 Python 解决

更多踩坑写在了 [SETUP.md](SETUP.md) 各步骤的备注里。

---

## 关于作者

福建农林大学空间信息专业在读，PM 方向，网文 AI 自动化写作的尝试者。代码和 AI 的结合点是最感兴趣的方向——不是纯写代码，也不是纯用 AI，而是搞清楚"怎么用 AI 写出对的代码"。

这个仓库是自己折腾的副产品，觉得可能有用的就整理出来了。

---

## 适用说明

- **新手**：最大的价值是省掉从零摸索的过程，直接有一套完整可用的环境
- **老手**：里面某些配置项（MCP 组合、RTK 集成、技能触发规则）或许能提供一个参考角度
- 这不一定是最好的方案，这就是我自己用下来觉得顺手的一套

大家如果有更好的配置思路或发现哪里写得不对，欢迎提 Issue 或 PR，一起把这套东西打磨得更好。

---

## 致谢

站在很多开源项目和社区贡献者的肩膀上。完整列表见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)，感谢每一位作者。

## 许可证

MIT
