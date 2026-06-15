# Claude Code + DeepSeek 随手折腾的配置

> 整理了一些日常用 Claude Code 接 DeepSeek 时顺手写的脚本，供参考。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](#)

[English](README_EN.md) · [详细设置指南](SETUP.md) · [DeepSeek适配细节](docs/DeepSeek适配细节.md)

---

> ⚠️ **前置说明**
>
> **1. 本仓库只做「项目内 CLAUDE.md / 指令 / Agent 模板」的生成与配置**
> — 不处理底层 API 转发。Claude Code 连接 DeepSeek 依赖 DeepSeek 官方 `/anthropic` 兼容接口，你需要自行配置全局 `~/.claude/settings.json` 和环境变量。
>
> **2. 唯一适配场景：Claude Code CLI + DeepSeek API**
> — 不兼容：网页版 Claude、Cursor、Roo Code、aider、Ollama 本地模型。
>
> **3. 所有配置项均针对 DeepSeek 模型行为调优**
> — 关闭了 Claude 专属特性的干扰、强制子 Agent 使用 pro 模型、缓存命中率优化。

---

## 三层架构：谁负责什么

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

| 现象 | 根因层 | 去哪解决 |
|------|--------|---------|
| 命令行卡顿、工具调用报错 | Claude Code CLI | [anthropics/claude-code](https://github.com/anthropics/claude-code) |
| 模型回复质量差、API 500 | DeepSeek API | [platform.deepseek.com](https://platform.deepseek.com) |
| MCP 启动失败、Agent 不工作、备份没触发 | 本仓库配置 | [提 Issue](https://github.com/YuhaoLin2005/deepseek-claude-code-starter/issues) |

---

## 适用人群

**适合你，如果你：**

- 用的是 **Claude Code CLI**（终端里的 `claude` 命令——不是 VSCode 插件、不是 Web 版）
- 用 **DeepSeek API** 作为后端
- 在 **Windows** 上开发（Mac/Linux 也能用，但部分路径要自己调）
- 不想从零折腾 MCP、Agent、规则——想 clone 下来直接用
- 在乎 Token 消耗，想提高缓存命中率

**不适合你，如果你：**

- 用的是 **Cursor / Copilot / Windsurf / Trae** 等 IDE 插件
- 用的是 **Anthropic 官方 API** 而不是 DeepSeek
- 期望**一键安装、零配置**（你需要改 `~/.mcp.json` 里的路径）
- 用的是 **Linux 服务器无桌面环境**（Playwright MCP 需要浏览器）

---

## 解决了几个问题

### ① 状态行实时压缩计数器

> 所有模型通用，Claude Code CLI 用户都能用。不限于 DeepSeek。

**问题**：长时间对话后，Claude Code 会自动压缩上下文（auto-compact）。每次压缩会把早期对话变成摘要——模型不再拥有完整上下文。压缩次数越多，模型"记忆退化"越严重，但用户完全不知道已经压缩了几次。

**做了什么**：`statusline.py` 追踪会话压缩次数——`total_input_tokens / 600K`，实时显示在终端底部状态行。

| 压缩次数 | 状态行显示 | 含义 |
|----------|-----------|------|
| 0 | 🟢 记忆完整 | 模型拥有完整上下文 |
| 1-2 | 🟢 压缩×N | 早期内容已摘要，正常范围 |
| 3-4 | 🟡 压缩×N ⚠ | 多层摘要叠加，细节可能丢失 |
| 5+ | 🔴 压缩×N 🔥 建议新会话 | 模型完全依赖摘要链，高幻觉风险 |

```bash
# 实际显示效果
claude-code-starter ▇▇▇▇░░░░░░ ● 35% | DS-v4-pro | 记忆完整
claude-code-starter ▇▇▇▇▇▇▇▇░░ ● 78% | DS-v4-pro | 压缩×4 ⚠
```

### ② DeepSeek 缓存命中率优化

**问题**：Claude Code 每次请求注入 `ATTRIBUTION_HEADER`（含会话 ID + 时间戳），DeepSeek 的 prompt 缓存把这些变动字段当作不同请求 → 命中率 ~50%。

**做了什么**：设 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 关闭后，命中率从 **~50% → 90%+**。

```bash
# 实测数据（RTK + 缓存命中叠加效果）
$ rtk gain --history
Tokens saved: 21.3K (54.4%)
```

### ③ 预配好的 MCP 和 Agent

默认 Claude Code 装完没有 MCP、没有自定义 Agent、没有规则。每个都要自己找 → 配 → 调兼容性。

**做了什么**：8 个 MCP 服务、9 个自定义 Agent、6 个规则文件，配好了、验证过、互相兼容。

### ④ 自动备份

AI 改代码是概率性的——有时对有时错。没有备份意味着每次改动都是赌博。

**备份机制**：

| 层 | 机制 | 触发时机 |
|----|------|---------|
| 文件级 | PreToolUse Hook：Edit/Write 前自动备份到 `.claude/backups/`（保留最近 5 份） | 每次修改前 |
| Session 级 | SessionStart Hook：启动时自动 `git commit` 所有未提交变更 | 每次启动 |
| 手动 | `git reset --hard HEAD~1` 回退 | 任何时候 |

### ⑤ Token 精简

`git status`、`npm install`、`ls -la`……这些命令的输出对 AI 来说是冗余信息，但每次都按 token 计费。

**做了什么**：RTK (Rust Token Killer) 自动精简 shell 命令输出，实测 **节省 55% token**。

---

## 包含的脚本和配置

| 类别 | 内容 |
|------|------|
| 状态行压缩计数 | 实时追踪会话压缩次数——告诉你模型还记得多少、什么时候该新开会话。所有模型通用。 |
| MCP 服务 (8) | 文件操作 · Playwright 浏览器 · GitHub API · PostgreSQL · Context7 文档查询 · DuckDuckGo 搜索 · 多引擎搜索 · Squish 持久记忆 |
| 自定义 Agent (9) | 代码审查 · 安全检查 · TDD 向导 · 架构设计 · 构建排错 · 代码简化 · 文档更新 · Rust 审查 · 高级实现 |
| 规则文件 (6) | 代码质量 · 安全 · 测试 · 工作流 · 性能 · 设计模式 |
| 场景模板 (3) | 前端项目 · 后端工程 · 算法数学 |
| 自动备份 | PreToolUse 文件快照 · SessionStart git commit · 手动 git reset |
| Token 优化 | RTK shell 输出精简 · 缓存命中率优化 · 子 Agent pro 模型 |
| 本地 OCR | EasyOCR 离线截图识别——DeepSeek 不支持图片输入，用这个绕开 |
| 脱敏扫描 | `/desensitize` 命令，push 前扫密钥/路径/内网 IP |
| 一键脚本 | `init.sh` 交互式初始化 · `update.sh` 一键更新规则 |

---

## 前置 API 配置（必须先配好）

Claude Code 连接 DeepSeek 靠 DeepSeek 官方 `/anthropic` 兼容接口。**以下配置不在本仓库能力范围内，必须提前手动配置。**

<details>
<summary>点击展开：全局 <code>~/.claude/settings.json</code> 完整配置（复制即用）</summary>

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-你的DeepSeek-API-Key",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1M]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1M]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-pro",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-pro",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "API_TIMEOUT_MS": "1200000"
  },
  "autoCompactEnabled": true,
  "autoCompactWindow": 600000,
  "alwaysThinkingEnabled": true,
  "fileCheckpointingEnabled": true,
  "showTurnDuration": true,
  "todoFeatureEnabled": true,
  "includeCoAuthoredBy": false,
  "theme": "dark"
}
```

> - `ANTHROPIC_AUTH_TOKEN` 换成你的 DeepSeek API Key（从 [platform.deepseek.com](https://platform.deepseek.com) 获取）
> - `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 是关键——关闭后缓存命中率从 50% 提升到 90%+
> - `CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-pro"` 强制所有子 Agent 用主力模型

</details>

---

## 快速开始

### 一键初始化

```bash
# 1. 配好全局 settings.json（见上方"前置 API 配置"）
# 2. 克隆并运行初始化脚本
git clone https://github.com/YuhaoLin2005/deepseek-claude-code-starter.git
cd deepseek-claude-code-starter
./init.sh
```

脚本会：检测 DeepSeek 配置 → 交互式选择项目类型 → 复制所有文件 → 输出收尾 checklist。

### 手动安装

```bash
git clone https://github.com/YuhaoLin2005/deepseek-claude-code-starter.git
cd deepseek-claude-code-starter
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json
# 编辑 ~/.mcp.json → 改 filesystem 路径
```

### 后续更新

```bash
# 在仓库目录内
./update.sh

# 或一行命令远程更新
curl -sL https://raw.githubusercontent.com/YuhaoLin2005/deepseek-claude-code-starter/main/update.sh | bash
```

> 📖 **卡住了？** 看 [详细设置指南](SETUP.md)。
>
> ⚠️ **RTK 是可选的**——不装也能用，装了省 55% token。安装方法见 [SETUP.md Step 5](SETUP.md#step-5安装-rtk可选推荐)。
>
> 📂 **多场景模板**：`templates/frontend/` · `templates/backend/` · `templates/math-alg/`，按需选用。

---

## 设计决策

几个可能会被问到"为什么不这样做"的点：

**为什么状态行显示压缩次数而不是成本？**
→ 成本是已知信息。压缩次数才是未知的：没人知道 Claude Code 在后台静默压缩了多少次。每次压缩会把早期对话变成摘要，压缩 5+ 次后幻觉概率显著上升。这个功能对所有模型后端通用。

**为什么不用 `settings.local.json` 存 API Key？**
→ 环境变量只有一个入口，不会不小心被 `git add -A` 一锅端。

**为什么子 Agent 也强制用 pro 模型？**
→ DeepSeek 的 flash 模型在复杂推理任务上产出质量明显下降。子 Agent 省下的 token 不够修 bug 的。

**为什么自动备份放 hook 而不是 crontab？**
→ Hook 在 Claude Code 进程内触发，精确到每次 Edit/Write。crontab 是时间驱动——改到一半崩溃了，它不会救你。

**为什么选 EasyOCR 而不是 mcp-vision？**
→ mcp-vision 依赖 DashScope API，认证不稳定且需联网。EasyOCR 跑在本地，够用。

**为什么配置放 `~/.claude/` 而不是项目级？**
→ 这些是用户级配置（规则、Agent、习惯），不是项目级。每个项目 clone 一次配置不合理，也容易版本分裂。

---

## 常见问题

### Q1：clone 这个仓库就能一键把 Claude Code 连上 DeepSeek 吗？

**不能。** 底层 API 互通依赖 DeepSeek 官方 `/anthropic` 兼容接口，你需要手动配置 `~/.claude/settings.json` 中的 `ANTHROPIC_BASE_URL` 和 API Key（见上方"前置 API 配置"章节）。本仓库处理的是"连通之后"的事情——MCP 服务、Agent、规则、备份、Token 优化。运行 `./init.sh` 可以帮你检测配置缺失。

### Q2：我用 Cursor / Roo Code / aider 可以用这套规则吗？

**不可以。** 本仓库的 Agent 定义、斜杠命令、Hook 全部基于 Claude Code CLI 的专有格式。其他工具的配置格式完全不同，规则无法复用。

### Q3：支持本地 Ollama 部署的 DeepSeek 模型吗？

**暂不支持。** 本仓库配置针对 DeepSeek 官方云端 API（`api.deepseek.com`）调优。Ollama 本地部署的 API 格式、缓存机制、模型行为均有差异，未做适配验证。

### Q4：Mac / Linux 能用吗？

**大部分能用，但需要自行调整。** MCP 的 filesystem 路径格式、RTK hook 路径、Python 脚本路径在 Mac/Linux 上写法不同。本仓库主要在 Windows 上验证——Mac/Linux 用户需要有一定的命令行配置经验。

### Q5：RTK 必须装吗？不装影响什么？

**不必须。** RTK 是可选组件——不装也能正常使用所有功能（MCP、Agent、备份、规则）。装了之后 shell 命令输出会自动精简，实测节省 ~55% token。安装方法见 [SETUP.md Step 5](SETUP.md#step-5安装-rtk可选推荐)。

### Q6：子 Agent 全部强制用 pro 模型，会不会很贵？

**不会。** DeepSeek V4 Pro 的定价约为 Claude Sonnet 4 的 1/15~1/20。加上缓存命中率 90%+ 和 RTK 省 55% token，实际日均费用不高。子 Agent 用 flash 模型省下的 token 往往不够修生成的 bug。

### Q7：状态行显示的压缩次数准吗？

**准确。** 压缩次数 = `total_input_tokens / autoCompactWindow(600K)`，直接从 Claude Code 的 JSON stdin 读取，不依赖任何外部 API。每次 auto-compact 触发后数字自增 1。所有 Claude Code CLI 用户（不管用什么模型后端）都能用。

### Q8：压缩次数高了除了新开会话还有别的办法吗？

**可以手动触发 compact 或降低上下文用量**——比如 `/compact` 命令、减少一次性加载的文件数量、关闭不需要的 MCP 服务。但最直接有效的方法还是新开一个会话。

---

## 踩坑笔记

- **状态行压缩次数**：比价格更有用的指标——告诉你模型还记得多少，压缩×5+ 建议新开会话。所有模型通用。
- **子 Agent 输出质量差**：默认用 flash 模型，设 `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro` 后正常
- **缓存命中率低（原理）**：`ATTRIBUTION_HEADER` 含会话 ID/时间戳变量，设 `"0"` 关闭后 50%→90%+
- **长文本上下文**：设 `autoCompactWindow=600K` + `CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000` + `alwaysThinkingEnabled=true`
- **Windows MCP 路径**：filesystem 服务器路径写双反斜杠 `C:\\Users\\...`，否则 JSON 解析失败
- **RTK 安装注意**：crates.io 上有重名包 `reachingforthejack/rtk` (Rust Type Kit)，别装错了
- **图片识别**：DeepSeek 不支持图片输入，改用 EasyOCR 本地识别（离线、免 API Key），脚本：`.claude/scripts/ocr.py`
- **PyTorch GPU**：QGIS 自带 Python 的 DLL 会冲突（`c10.dll 1114`），装独立 Python 解决

---

## 路线图

- [x] `init.sh` 一键初始化脚本
- [x] `update.sh` 一键同步最新规则模板
- [x] `statusline.py` 压缩次数状态行（模型无关，所有 Claude Code CLI 用户通用）
- [ ] 更多技术栈模板（Java/Spring、Go、Rust）
- [ ] DeepSeek 新模型适配跟进

欢迎 PR 贡献！

---

## 致谢

站在很多开源项目和社区贡献者的肩膀上。完整列表见 [ATTRIBUTIONS.md](ATTRIBUTES.md)。

## 许可证

MIT
