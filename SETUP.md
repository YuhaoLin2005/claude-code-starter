# 设置指南

从零到完整配置，预计 10-15 分钟。

## 前置条件

- [ ] Claude Code 已安装（`claude --version`）
- [ ] Node.js ≥ 18（`node --version`）
- [ ] Git Bash 或 WSL（Windows 用户）

---

## 第一步：获取 API Key

### 必须
1. 注册 [DeepSeek 平台](https://platform.deepseek.com)
2. 进入 API Keys 页面，创建 Key
3. 充值（最低 ¥10，够用很久）

### 可选
- **DashScope API Key**（图片分析功能）：[dashscope.aliyun.com](https://dashscope.aliyun.com)
- **GitHub Personal Access Token**（GitHub MCP）：Settings → Developer settings → Tokens (classic)，勾选 `repo`、`read:org`、`workflow`

---

## 第二步：设置环境变量

### Windows（在 Git Bash 中执行）
```bash
setx ANTHROPIC_API_KEY "sk-your-deepseek-key"
setx ANTHROPIC_BASE_URL "https://api.deepseek.com/anthropic"
# 以下可选
setx GITHUB_PERSONAL_ACCESS_TOKEN "ghp_xxx"
setx DASHSCOPE_API_KEY "sk-xxx"
setx PGPASSWORD "your-db-password"
```

### macOS / Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export ANTHROPIC_API_KEY="sk-your-deepseek-key"
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxx"      # 可选
export DASHSCOPE_API_KEY="sk-xxx"                   # 可选
export PGPASSWORD="your-db-password"                # 可选
```

重启终端使环境变量生效。

---

## 第三步：安装可选工具

### RTK（Token 优化，推荐）
```bash
cargo install rtk
# 或者
cargo install --git https://github.com/reachingforthejack/rtk
```

### GitHub CLI
```bash
winget install GitHub.cli     # Windows
brew install gh               # macOS
sudo apt install gh           # Linux
gh auth login
```

### uv（Vision MCP 需要）
```bash
pip install uv
# 或
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### PostgreSQL（数据库 MCP 需要）
已安装的话确保 `psql` 可用。

---

## 第四步：复制配置

```bash
# 克隆仓库
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter

# 复制核心配置
cp -r .claude/* ~/.claude/

# 复制 MCP 配置模板
cp templates/mcp.json.example ~/.mcp.json

# 复制本地设置模板
cp templates/settings.local.json.example ~/.claude/settings.local.json
```

---

## 第五步：编辑本地配置

### 1. `~/.mcp.json`
修改 `filesystem` 的路径为你自己的项目目录：
```json
"args": ["-y", "@modelcontextprotocol/server-filesystem", "/你的/项目路径", "/你的/桌面路径"]
```

如果不需要某个 MCP 服务，直接删除对应条目。

### 2. `~/.claude/settings.local.json`
这是权限配置文件。检查并按需调整。**不需要改也能用。**

---

## 第六步：验证

```bash
# 启动 Claude Code
claude

# 在 Claude Code 中验证：
# 1. 输入 /status 查看模型配置
# 2. 输入 /mcp 查看 MCP 服务状态
# 3. 试试 "帮我搜一下今天的热点新闻" 测试搜索
# 4. 试试 "审查当前代码" 测试 Agent
```

---

## Windows 用户额外步骤

确保 Git Bash 已安装并配置为终端：
```bash
# Claude Code settings.json 中
"preferredShell": "C:\\Program Files\\Git\\bin\\bash.exe"
```

RTK hook 路径在 Git Bash 中：
```bash
which rtk
# 通常输出: /c/Users/你的用户名/.cargo/bin/rtk
```

---

## 常见问题

### Q: 启动后显示 "API key not found"
```bash
echo $ANTHROPIC_API_KEY  # 确认环境变量
# Windows 用户注意：setx 只对新开的终端生效
```

### Q: MCP 服务启动失败
- 确认 Node.js >= 18
- 确认对应包已安装：`npx -y @modelcontextprotocol/server-filesystem --help`
- Windows 路径用双反斜杠 `C:\\Users\\...`

### Q: RTK hook 报错
- RTK 是可选的，删除 `settings.json` 中的 `hooks` 部分即可禁用

### Q: 我想用 Anthropic API 不用 DeepSeek
编辑 `~/.claude/settings.json`，把 `ANTHROPIC_BASE_URL` 和模型名改回默认值。

---

## 定制建议

| 需求 | 操作 |
|------|------|
| 只要代码审查 | 删除不需要的 Agent 文件 |
| 不要 MCP | 清空 `.mcp.json` 中的 `mcpServers` |
| 只要基础规则 | 删除 `rules/` 下不需要的文件 |
| 换用其他模型 | 修改 `settings.json` 中的 `ANTHROPIC_MODEL` |

搞不定？[提 Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues)。
