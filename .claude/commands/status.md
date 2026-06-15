---
description: 查看 Claude Code 配置状态总览
---

# /status — 配置状态总览

运行配置健康检查脚本，一键查看所有配置状态。

## 执行步骤

### 1. 运行检查脚本

```bash
python ~/.claude/scripts/config-check.py
```

如需快速模式（跳过耗时检查）：

```bash
python ~/.claude/scripts/config-check.py --quick
```

### 2. 检查内容

脚本会自动检查以下项目：

| 类别 | 检查项 |
|------|--------|
| 核心配置 | settings.json 语法、.mcp.json 语法 |
| 环境变量 | API 网关、模型名称、缓存优化、超时设置 |
| 规则 & Agent | 规则文件数量、Agent 定义数量 |
| MCP 服务 | 所有服务配置、是否有硬编码密钥 |
| 备份系统 | PreToolUse Hook、SessionStart Hook、备份文件 |
| Hooks | RTK Hook、备份 Hook |
| Windows 路径 | 双反斜杠格式检查 |

### 3. 输出

- 每项标记 ✓ / ✗ / ⚠
- 问题项附带具体修复建议
- 汇总通过/失败数量
