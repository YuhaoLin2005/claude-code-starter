# claude-code-deepseek-starter

整理了一些 Claude Code + DeepSeek 组合中常用的脚本和配置。  
主要解决 DeepSeek 数据陈旧、无视觉能力、无自动备份等问题。

## 目录结构

```
.claude/
├── agents/       # 自定义 Agent（代码审查、安全、TDD 等 9 个）
├── rules/        # 规则文件（代码质量、安全、测试等 6 个）
├── scripts/      # 脚本（OCR、状态行、备份等）
├── skills/       # 自定义技能
└── commands/     # 斜杠命令
templates/        # 项目模板（前端/后端/算法）
init.sh           # 一键初始化
update.sh         # 一键更新
```

## 依赖

- DeepSeek API Key（[platform.deepseek.com](https://platform.deepseek.com)）
- EasyOCR（`pip install easyocr`，本地 OCR 用）
- Git（自动备份依赖）
- DuckDuckGo MCP server（搜索功能）

## 安装

```bash
git clone https://github.com/YuhaoLin2005/deepseek-claude-code-starter.git
cd deepseek-claude-code-starter
./init.sh   # 自动检测配置 → 交互式选择 → 链接到 ~/.claude/
```

详细说明见 [SETUP.md](SETUP.md)。

## 各模块说明

- **状态行**：显示上下文压缩次数，所有模型通用。压缩 5+ 次建议新开会话。
- **自动备份**：每次修改前自动备份文件（保留最近 5 份）+ 会话启动自动 git commit。
- **OCR**：调用本地 EasyOCR 识别截图，让 DeepSeek 能"看懂"图片（离线，不经过 API）。
- **搜索**：通过 DuckDuckGo MCP 补足 DeepSeek 训练数据时效问题。
- **RTK**：精简 shell 命令输出，减少 token 消耗（可选组件）。

## 已知局限

- OCR 速度取决于本地硬件
- 缓存不做语义相似判断，只精确匹配
- 备份路径固定，修改需改脚本
- 主要在 Windows 上验证，Mac/Linux 需自行调整路径
- 不处理底层 API 转发——需自行配置 `~/.claude/settings.json` 中的 `ANTHROPIC_BASE_URL` 和 API Key

## 参考与致谢

- 搜索部分基于 MCP 官方服务器
- OCR 部分参考 EasyOCR 官方示例
- 完整致谢见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)

## License

MIT
