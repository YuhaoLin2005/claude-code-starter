# 详细设置指南

一步一步从零配好 Claude Code + DeepSeek on Windows。

---

## 准备工作

| 你需要 | 怎么获取 |
|--------|---------|
| **DeepSeek API Key** | [platform.deepseek.com](https://platform.deepseek.com) 注册 → API Keys → 创建 |
| **Node.js** (v18+) | [nodejs.org](https://nodejs.org) 下载 LTS 版安装 |
| **Python 3.10+** | [python.org](https://python.org) 下载安装，**勾选 "Add to PATH"** |
| **Git for Windows** | [git-scm.com](https://git-scm.com) 下载安装 |
| **Claude Code CLI** | 见下方 Step 1 |
| **RTK** (可选，推荐) | 见下方 Step 5 |

---

## Step 1：安装 Claude Code

```powershell
npm install -g @anthropic-ai/claude-code
```

验证：
```powershell
claude --version
```

---

## Step 2：设置 API Key

```powershell
# 方式 A：环境变量（推荐，重启终端后生效）
setx ANTHROPIC_API_KEY "sk-your-deepseek-key"

# 方式 B：settings.local.json（优先级更高）
# 复制 templates/settings.local.json.example → ~/.claude/settings.local.json
# 建议用方式 A，避免文件泄露
```

---

## Step 3：克隆配置仓库

```powershell
git clone https://github.com/YuhaoLin2005/deepseek-claude-code-starter.git
cd deepseek-claude-code-starter
```

---

## Step 4：复制配置文件

### 4.1 核心配置（~/.claude/）

```powershell
# 复制规则文件
cp -r .claude/rules/ $env:USERPROFILE\.claude\rules\

# 复制 Agent 定义
cp -r .claude/agents/ $env:USERPROFILE\.claude\agents\

# 复制命令
cp -r .claude/commands/ $env:USERPROFILE\.claude\commands\

# 复制 CLAUDE.md
cp .claude\CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md
cp .claude\RTK.md $env:USERPROFILE\.claude\RTK.md
```

### 4.2 MCP 服务器配置

```powershell
# 复制模板
cp templates\mcp.json.example $env:USERPROFILE\.mcp.json
```

**重要：** 编辑 `~\.mcp.json`，把 filesystem 服务器里的路径改成你自己的：

```json
"filesystem": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "C:\\Users\\你的用户名\\Desktop"
  ]
}
```

> ⚠️ Windows 路径必须写双反斜杠 `\\`，否则 JSON 解析失败。

### 4.3 DeepSeek 后端配置

复制 `templates\settings.json.example` 到 `~\.claude\settings.json`（或与已有 settings.json 合并）。

核心 env 配置（使 Claude Code 走 DeepSeek API）：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8000",
    "API_TIMEOUT_MS": "1200000",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "autoCompactWindow": 600000
  },
  "alwaysThinkingEnabled": true
}
```

> 💡 **模型分流策略**（Pro 主控 + Flash 子代理）：主 Agent 承载深度推理，使用 Pro 模型保证质量；子 Agent 被自动派去读文件、搜索代码、跑测试等一次性杂活，使用 Flash 模型处理。Pro 缓存命中后价格与 Flash 接近，但缓存未命中时成本是 Flash 的 3 倍——子代理任务缓存命中率天然低（每次读不同文件），用 Flash 正好规避了这个成本陷阱。
>
> 💡 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 关闭追踪头，有助于保持 DeepSeek 缓存命中率稳定。`MAX_OUTPUT_TOKENS=8000` 覆盖绝大多数场景，大重构时可按需手动调高。

---

## Step 5：安装 RTK（可选，推荐）

RTK 自动精简 Shell 命令输出，实测节省 55-80% token。

```powershell
# 安装 Rust（如果没有）
# https://rustup.rs → 下载 rustup-init.exe 运行

# 安装 RTK
cargo install rtk

# 验证
rtk --version
rtk gain
```

> ⚠️ crates.io 上有个重名包 `reachingforthejack/rtk` (Rust Type Kit)，别装错了。你需要的包名就是 `rtk`。

---

## Step 6：安装本地 OCR（可选）

DeepSeek 不支持图片输入，EasyOCR 提供离线截图文字识别：

```powershell
pip install easyocr opencv-python
```

首次运行会自动下载模型（约 200MB，仅一次）。使用：

```powershell
python ~/.claude/scripts/ocr.py screenshot.png
```

---

## Step 7：重启 Claude Code

关掉所有终端窗口，重新打开，运行：

```powershell
claude
```

---

## 验证一切正常

进入 Claude Code 后：

```
# 检查 MCP 服务状态
/mcp

# 检查 Agent 列表
ls ~/.claude/agents/

# 检查规则文件
ls ~/.claude/rules/

# 跑一次 RTK 统计
rtk gain
```

8 个 MCP 服务全部显示绿色 ✅ 即配置成功。

---

## 常见问题

### `claude` 命令找不到

npm 全局安装路径不在 PATH 中。用 `npm list -g --depth=0` 查看安装位置，手动加到 PATH。

### MCP 服务启动失败

1. 检查 Node.js 版本：`node --version`（需 >= 18）
2. 检查 `.mcp.json` 语法：复制到 [jsonlint.com](https://jsonlint.com) 验证
3. 检查 filesystem 路径是否存在且为双反斜杠

### DeepSeek 返回错误

1. API Key 是否正确：`echo $env:ANTHROPIC_API_KEY`
2. 账户是否有余额：[platform.deepseek.com](https://platform.deepseek.com)
3. `ANTHROPIC_BASE_URL` 是否正确

### 缓存命中率低

1. 确认 `CLAUDE_CODE_ATTRIBUTION_HEADER` 设为 `"0"`
2. DeepSeek 缓存是前缀匹配——多轮对话和长 system prompt 复用场景下命中率最高
3. 单次短请求天然不会命中缓存，属正常现象

### RTK hook 报错

RTK 是可选的。如果需要禁用，删除 `~/.claude/settings.json` 中 `hooks` 部分。

### 我想用 Anthropic API 不用 DeepSeek

编辑 `~/.claude/settings.json`，去掉 `ANTHROPIC_BASE_URL` 和模型相关 env 配置，恢复默认值。

---

## 下一步

- 阅读 [README.md](README.md) 了解完整功能
- 看看 [踩坑笔记](README.md#踩坑笔记) 避开已知问题
- 有问题提 [Issue](https://github.com/YuhaoLin2005/deepseek-claude-code-starter/issues)
