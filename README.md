# Claude Code + DeepSeek 完整配置方案

> **专为「Claude Code CLI + DeepSeek API」用户设计。** 不是通用配置——是踩完坑验证过、clone 下来改两个路径就能干活的工程化方案。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](#)
[![Model: DeepSeek](https://img.shields.io/badge/Model-DeepSeek_v4_Pro-green.svg)](#)
[![RTK: 55% Savings](https://img.shields.io/badge/RTK-55%25_Token_Savings-purple.svg)](#)

[English](README_EN.md) · [详细设置指南](SETUP.md)

---

## 开始之前——请先读完这里

### 这个仓库是什么

**Claude Code CLI 配 DeepSeek 这件事，中间有一层"工程胶水"——MCP 怎么配、缓存怎么调、子 Agent 用什么模型、改坏了怎么回退。** 这个仓库就是这层胶水。

它不是 Claude Code 的替代品，也不是 DeepSeek 的封装。它是在这两层之上的**配置 + 规则 + 工具链**。

### 三层架构：谁负责什么

```
┌──────────────────────────────────────────────────┐
│           本仓库（配置 & 工具层）                   │
│  MCP 服务 · 自定义 Agent · 规则文件 · Hooks        │
│  RTK 省 Token · 自动备份 · 脱敏扫描 · OCR           │
│  → 这一层的问题，提 Issue 给我                      │
├──────────────────────────────────────────────────┤
│          Claude Code CLI（工具层）                  │
│  Agent 循环 · 工具调用 · 权限系统 · UI · 插件       │
│  → 由 Anthropic 维护，本仓库不修改也不负责           │
├──────────────────────────────────────────────────┤
│           DeepSeek API（模型层）                    │
│  LLM 推理 · Prompt 缓存 · Token 计费                │
│  → 由深度求索提供，本仓库只做适配配置                │
└──────────────────────────────────────────────────┘
```

**理解这个分层很重要——遇到问题时你知道该找谁：**

| 现象 | 根因层 | 去哪解决 |
|------|--------|---------|
| 命令行卡顿、工具调用报错 | Claude Code CLI | [anthropics/claude-code](https://github.com/anthropics/claude-code) |
| 模型回复质量差、API 500 | DeepSeek API | [platform.deepseek.com](https://platform.deepseek.com) |
| MCP 启动失败、Agent 不工作 | 本仓库配置 | [提 Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues) |

### 适用人群（请对号入座）

**✅ 你适合用这个仓库，如果你：**

- 用的是 **Claude Code CLI**（终端里的 `claude` 命令——不是 VSCode 插件、不是 Web 版、不是 API SDK）
- 用 **DeepSeek API** 作为后端（不是因为没钱——是因为 DeepSeek 在性价比上确实能打）
- 在 **Windows** 上开发（Mac/Linux 也能用，但部分路径要自己改）
- 不想从零折腾 MCP、Agent、规则文件——想 clone 下来直接干活
- 在乎 Token 消耗，想知道怎么把缓存命中率从 50% 拉到 90%+

**❌ 你不适合用这个仓库，如果你：**

- 用的是 **Cursor / Copilot / Windsurf / Trae** 等 IDE 插件（这些不是 Claude Code CLI，这是两个东西）
- 用的是 **Anthropic 官方 API** 而不是 DeepSeek（缓存优化、模型配置等对你没用——你不需要绕这些弯）
- 期望**一键安装、零配置**（你需要改 `~/.mcp.json` 里的路径——这是 CLI 工具，不是 SaaS）
- 需要的是"最好"的配置（这里只有"踩过坑、确定能用"的配置）
- 用的是 **Linux 服务器无桌面环境**（Playwright MCP 需要浏览器，本配置未适配 headless 场景）

---

## 解决四个核心问题

### ① DeepSeek 缓存命中率只有 ~50%

**根因**：Claude Code 每次请求注入 `ATTRIBUTION_HEADER`（含会话 ID + 时间戳），DeepSeek 的 prompt 缓存把这些变动字段当作不同请求 → 命中率腰斩。

**解决**：设 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 关闭后，命中率从 **~50% → 90%+**。每次请求省一半 token。

```bash
# 实测数据（RTK + 缓存命中叠加效果）
$ rtk gain --history
Tokens saved: 21.3K (54.4%)
```

### ② 从零配到顺手，没几天搞不定

默认 Claude Code 装完是"裸"的——没有 MCP、没有自定义 Agent、没有规则。每个人都要重新踩一遍：找包 → 配参数 → 调兼容性 → 放弃 → 再来。

**本仓库做了什么**：8 个 MCP 服务、9 个自定义 Agent、6 个规则文件，全部配好、验证过、互相兼容。**clone → 复制 → 改两个路径 → 能用。**

### ③ AI 改坏了没有后悔药

AI 改代码是概率性的——有时对有时错。没有备份意味着每次改动都是赌博。

**三层自动备份**，从 Edit 前快照到 Session 级 git commit 到手动回退：

| 层 | 机制 | 触发时机 |
|----|------|---------|
| 文件级 | PreToolUse Hook：Edit/Write 前自动备份到 `.claude/backups/`（保留最近 5 份） | 每次修改前 |
| Session 级 | SessionStart Hook：启动时自动 `git commit` 所有未提交变更 | 每次启动 |
| 手动 | `git reset --hard HEAD~1` 一键回退 | 任何时候 |

### ④ Token 全浪费在命令行输出上了

`git status`、`npm install`、`ls -la`……这些命令的输出对 AI 来说是冗余信息，但每次都原样喂给模型，按 token 计费。

**解决**：RTK (Rust Token Killer) 自动精简所有 shell 命令输出，实测 **节省 55% token**。对 AI 没用的信息直接裁掉，对 AI 有用的保留。

---

## 和直接用 Claude Code 有什么区别

| 维度 | 裸装 `npm install -g @anthropic-ai/claude-code` | 加上本仓库配置 |
|------|:--:|:--:|
| MCP 服务 | 0（需要自己找包、配参数、调兼容） | **8 个**，即配即用 |
| 自定义 Agent | 默认内置 Agent | **9 个**专业 Agent（审查/安全/TDD/架构…） |
| 子 Agent 模型 | flash 模型（复杂任务质量不够） | **强制 pro 模型** |
| 缓存命中率 | ~50%（ATTRIBUTION_HEADER 干扰） | **90%+**（已关闭） |
| 自动备份 | ❌ 无 | **3 层**自动备份 |
| Token 优化 | ❌ 无 | **RTK 节省 55%** |
| Windows 路径 | ⚠️ 需自己调 | **已调好** |
| 公开仓库安全 | ❌ 无检查 | **脱敏扫描**（4 级分类） |
| 配置时间 | 几天（一个个踩坑） | **15 分钟** |

---

## 快速开始

```bash
# 1. 注册 DeepSeek 获取 API Key → https://platform.deepseek.com
# 2. 克隆仓库
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter

# 3. 复制配置
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json

# 4. 编辑 ~/.mcp.json，把 filesystem 路径改成你自己的（就这一处）
#    找到 "C:\\Users\\xxx" → 改成你的用户名

# 5. 设置环境变量（二选一）
#    Windows: setx ANTHROPIC_API_KEY "sk-your-deepseek-key"
#    Mac/Linux: export ANTHROPIC_API_KEY="sk-your-deepseek-key"
#    然后重启终端使环境变量生效

# 6. 启动
claude
```

> 📖 **卡住了？** 看 [详细设置指南](SETUP.md)，每一步都有截图和说明。
>
> ⚠️ **RTK 是可选的**——不装也能用，装了省 55% token。安装方法见 [SETUP.md Step 5](SETUP.md#step-5安装-rtk可选推荐)。

---

## 功能全景

| 类别 | 内容 |
|------|------|
| 🧩 **MCP 服务** (8) | 文件操作 · Playwright 浏览器 · GitHub API · PostgreSQL · Context7 文档查询 · DuckDuckGo 搜索 · Parallel 多引擎搜索 · Squish 持久记忆 |
| 🤖 **自定义 Agent** (9) | 代码审查 · 安全检查 · TDD 向导 · 架构设计 · 构建排错 · 代码简化 · 文档更新 · Rust 审查 · 高级实现 |
| 📋 **规则文件** (6) | 代码质量 · 安全 · 测试 · 工作流 · 性能 · 设计模式 |
| 🛡️ **自动备份** (3 层) | PreToolUse 文件快照 · SessionStart git commit · 手动 git reset |
| ⚡ **Token 优化** | RTK shell 输出精简（实测 55%） · 缓存命中率优化（50%→90%+） · 子 Agent pro 模型 |
| 🔍 **本地 OCR** | EasyOCR 离线截图识别——DeepSeek 不支持图片输入，用这个绕开 |
| 🔒 **脱敏扫描** | `/desensitize` 命令，push 前扫密钥/路径/内网 IP（4 级分类，支持白名单） |
| ⌨️ **快捷键** | `Alt+T` 切换思考模式 · `Ctrl+O` 查看推理过程 |

---

## 📸 截图

| RTK 令牌节省 (55%) | 自定义 Agent (9) |
|:---:|:---:|
| ![RTK Gain](screenshots/02-rtk-gain.png) | ![Agents](screenshots/03-agents.png) |

---

## 设计决策

几个可能会被问到"为什么不这样做"的点：

**为什么不用 `settings.local.json` 存 API Key？**
→ 环境变量只有一个入口，不会不小心被 `git add -A` 一锅端。`settings.local.json` 在用户目录下容易被误提交。

**为什么子 Agent 也强制用 pro 模型？**
→ DeepSeek 的 flash 模型在复杂推理任务（代码审查、安全分析）上产出质量明显下降。子 Agent 省下的 token 不够修 bug 的。

**为什么自动备份放 hook 而不是 crontab？**
→ Hook 在 Claude Code 进程内触发，精确到每次 Edit/Write。crontab 是时间驱动——改到一半崩溃了，它不会救你。

**为什么选 EasyOCR 而不是 mcp-vision？**
→ mcp-vision 依赖 DashScope API，认证机制不稳定且需联网。EasyOCR 跑在本地，中文识别率 85%+，够用。

**为什么配置放 `~/.claude/` 而不是项目级？**
→ 这些是用户级配置（规则、Agent、工作习惯），不是项目级。每个项目 clone 一次配置不合理，也容易版本分裂。

---

## 踩坑笔记

- **子 Agent 输出质量差**：默认用 flash 模型，设 `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro` 后正常
- **缓存命中率低（原理）**：`ATTRIBUTION_HEADER` 含会话 ID/时间戳变量，设 `"0"` 关闭后 50%→90%+
- **长文本上下文**：设 `autoCompactWindow=600K` + `CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000` + `alwaysThinkingEnabled=true`
- **Windows MCP 路径**：filesystem 服务器路径写双反斜杠 `C:\\Users\\...`，否则 JSON 解析失败
- **RTK 安装注意**：crates.io 上有重名包 `reachingforthejack/rtk` (Rust Type Kit)，别装错了
- **图片识别**：DeepSeek 不支持图片输入，改 EasyOCR 本地识别（离线、免 API Key），脚本：`.claude/scripts/ocr.py`
- **PyTorch GPU**：QGIS 自带 Python 的 DLL 会冲突（`c10.dll 1114`），装独立 Python 解决

---

## 致谢

站在很多开源项目和社区贡献者的肩膀上。完整列表见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)。

## 许可证

MIT
