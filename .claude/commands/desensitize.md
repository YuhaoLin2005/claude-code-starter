---
description: 公开仓库脱敏审查 — 扫描敏感信息，防止密钥/路径泄露
---

# /desensitize — 脱敏审查

在 push 到公开仓库之前，自动扫描项目中是否包含敏感信息。

## 执行步骤

### 1. 运行扫描脚本

```bash
python ~/.claude/scripts/desensitize.py <project_directory>
```

如果用户只关心即将 push 的内容（推荐），使用 `--staged`：

```bash
python ~/.claude/scripts/desensitize.py <project_directory> --staged
```

### 2. 解读结果

扫描会检测 4 个级别的问题：

| 级别 | 说明 | 处理 |
|------|------|------|
| 🔴 CRITICAL | 真实密钥（GitHub Token、AWS Key、API Key 等） | **必须修复，禁止 push** |
| 🟠 HIGH | 个人路径、硬编码密码 | **必须修复或脱敏** |
| 🟡 MEDIUM | 内网 IP、数据库连接串 | 建议替换为占位符 |
| ⚪ LOW | 邮箱、HTTP 链接、端口号 | 酌情处理 |

### 3. 修复问题

对于每个发现，自动执行以下操作：

**CRITICAL/HIGH：**
- 将硬编码密钥替换为环境变量引用（如 `process.env.MY_KEY`）
- 将 Windows 路径 `C:\Users\xxx\...` 替换为 `~/.claude/...` 或 `$HOME/...`
- 将真实值替换为占位符（`your-key-here`）
- 检查 `.gitignore` 是否排除包含敏感信息的文件

**MEDIUM：**
- 内网 IP 替换为示例 IP（`192.168.1.100` → `10.0.0.1`）
- 连接串中的真实主机/密码替换为占位符

**LOW：**
- 个人邮箱考虑替换为 GitHub 关联邮箱或删除
- HTTP 链接确认是否必须为 HTTP（非 HTTPS）

### 4. 添加白名单

如果某些匹配是误报（如文档中的示例），在项目根目录创建 `.desensitize-allow`：

```
# .desensitize-allow — 每行一个正则，匹配的内容将跳过检查
example@email\.com
dummy-api-key-123
```

### 5. 验证通过

```bash
# 再次扫描确认 0 issue
python ~/.claude/scripts/desensitize.py <project_directory>
# 应输出：✅ No sensitive data found — safe to push!
```

## 输出

- 按严重级别分组的问题列表
- 每个匹配的文件路径、行号、上下文
- 最终判断：是否可以安全 push
