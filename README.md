# Claude Code 开箱即用配置：DeepSeek + Windows 完整方案

> A battle-tested Claude Code configuration for DeepSeek API on Windows. 8 MCP services, 9 custom agents, 3-layer auto-backup, local OCR, and RTK token optimization — everything you need to go from zero to productive in 15 minutes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](#)
[![Model: DeepSeek](https://img.shields.io/badge/Model-DeepSeek_v4_Pro-green.svg)](#)
[![RTK: 55% Savings](https://img.shields.io/badge/RTK-55%25_Token_Savings-purple.svg)](#)

---

## 📸 截图

| RTK 令牌节省 (55%) | 自定义 Agent (9) |
|:---:|:---:|
| ![RTK Gain](screenshots/02-rtk-gain.png) | ![Agents](screenshots/03-agents.png) |

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
| 🧩 **MCP 服务** | 8 | 文件操作 · 浏览器自动化 · GitHub · PostgreSQL · 文档搜索(Context7) · 搜索(DuckDuckGo) · 并行搜索(Parallel，多引擎同时查) · 持久化记忆(Squish) |
| 🤖 **自定义 Agent** | 9 | 代码审查 · 安全检查 · TDD 向导 · 架构设计 · 构建排错 · 代码简化 · 文档更新 · Rust 审查 · 高级实现 |
| 📋 **规则文件** | 6 | 代码质量 · 安全 · 测试 · 工作流 · 性能 · 设计模式 |
| 🛡️ **自动备份** | 3 层 | Hook 文件级备份（每次 Edit/Write 自动备份原文件）· SessionStart 快照（启动自动 git commit）· Git 兜底（手动回退到任意版本） |
| ⚡ **RTK 集成** | — | Shell 命令自动精简，实测节省 55% token |
| 🚀 **并行执行** | — | 子 Agent 并行处理 + 多引擎并行搜索，独立任务同时跑，效率翻倍 |
| 🔍 **本地 OCR** | — | EasyOCR 离线截图文字识别，免 API Key，中文识别准确率 85%+，比 mcp-vision 更稳定 |
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

- **子 Agent 输出质量差**：默认用了 flash 模型处理子任务，复杂逻辑产出低下。设 `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro` 强制子 Agent 也用主力模型后正常
- **缓存命中率低（原理）**：Claude Code 每次请求会自动注入 `ATTRIBUTION_HEADER`（含会话 ID、时间戳等变量信息），DeepSeek 的 prompt cache 会把这些变动字段当作"不同请求"，导致缓存命中率仅 ~50%。设 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 关闭后从 50% 提升到 90%+，相当于每次请求少花一半 token
- **长文本上下文利用**：DeepSeek V4 Pro 支持 1M 上下文，但默认紧凑阈值偏保守。设置 `autoCompactWindow=600K` + `CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000` + `alwaysThinkingEnabled=true`，大重构不丢上下文、长输出不截断、复杂推理不省略
- **并行执行加速**：同类独立任务（多个 agent 审查、多引擎搜索）通过并行调度同时执行，不用排队等。`parallel-search` MCP 一次发多条搜索、子 Agent 池化复用
- **Windows MCP 路径**：filesystem 服务器的路径要写双反斜杠 `C:\\Users\\...`
- **RTK 安装注意**：crates.io 上有个重名包 reachingforthejack/rtk (Rust Type Kit)，别装错了，要装 token-optimizer 那个
- **图片识别方案**：DeepSeek 不支持图片输入。mcp-vision (DashScope API) 因认证机制不稳定已弃用，改用 **EasyOCR 本地识别**（`pip install easyocr`，离线运行，中文识别 85%+，免 API Key）。脚本：`.claude/scripts/ocr.py`
- **PyTorch GPU**：QGIS 自带 Python 的 DLL 会冲突 (c10.dll 1114)，装独立 Python 解决

更多踩坑写在了 [SETUP.md](SETUP.md) 各步骤的备注里。

---

## 关于作者

大三在读学生，PM 方向，网文 AI 自动化写作的尝试者。代码和 AI 的结合点是最感兴趣的方向——不是纯写代码，也不是纯用 AI，而是搞清楚"怎么用 AI 写出对的代码"。

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
