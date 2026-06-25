# deepseek-claude-code-starter

Claude Code + DeepSeek 组合的脚本和配置集——让 DeepSeek 在 Claude Code 中发挥出接近原生的体验。  
*Scripts and configs for the Claude Code + DeepSeek combo — near-native DeepSeek experience inside Claude Code.*

## 核心优化

- **🧠 模型分流**：主 Agent 用 Pro 做深度推理，子 Agent 用 Flash 处理读文件/搜索/测试等杂活。充分利用 DeepSeek 磁盘缓存（缓存命中 $0.014/M，成本直降 90%），子代理用 Flash 规避高缓存未命中率下的成本风险。
- **🦥 YAGNI 懒人法则**：融合 ponytail（46K+ stars）哲学，6级决策阶梯——标准库能做的不用写、平台能力覆盖的不用写、一行搞定的不用写五十行。`ponytail:` 注释约定让刻意简化可见可追踪。
- **📦 一键部署**：`./init.sh` 自动检测环境、交互式选择组件、符号链接到 `~/.claude/`。
- **🔄 自动备份**：每次修改前备份文件（保留最近 5 份）+ 会话启动自动 git commit。
- **🛡️ 安全阻断**：PreToolUse hook 自动拦截敏感文件访问（.env、.ssh、credentials）和危险命令（rm -rf /、force push main）。
- **🔍 搜索补强**：DuckDuckGo MCP 补足 DeepSeek 训练数据时效。
- **👁️ 本地 OCR**：EasyOCR 离线识别截图，让 DeepSeek 能"看懂"图片。
- **📊 状态行**：显示上下文压缩次数，压缩 5+ 次提醒新开会话。
- **⚡ RTK 集成**：自动精简 Shell 命令输出，实测节省 55-80% token。
- **🎨 自动格式化**：Edit/Write 后自动 prettier 格式化前端文件（可选，检测不到自动跳过）。

## 目录结构

```
.claude/
├── agents/       # 自定义 Agent（代码审查、安全、TDD 等 9 个）
├── rules/        # 规则文件（代码质量、安全、测试、YAGNI 等 7 个）
├── scripts/      # 脚本（安全阻断、自动格式化、OCR、状态行、备份等）
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

- **YAGNI 懒人法则**：每次编码前走6级决策阶梯——从"这需要存在吗？"到"写最小代码"——防止过度工程。`ponytail:` 注释让推迟的复杂度可见可收割。
- **安全阻断**：自动拦截敏感文件读取（.env、.ssh、credentials、tokens）和危险命令（rm -rf /、git push --force main、curl | bash）。是安全建议的硬执行层。
- **自动格式化**：修改 .vue/.js/.ts/.css/.html 文件后自动运行 prettier 格式化，未安装则安静跳过。
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

## 相关项目

- [claude-code-engineering-system](https://github.com/YuhaoLin2005/claude-code-engineering-system) — 本脚手架背后的方法论框架：对抗性自我审计/双轨记忆/三层安全/任务分流
- [compact-counter-concept](https://github.com/YuhaoLin2005/compact-counter-concept) — 状态行中的压缩次数监控，发现压缩非线性效应

## 参考与致谢

- YAGNI 决策阶梯融合自 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)（MIT License）
- 搜索部分基于 MCP 官方服务器
- OCR 部分参考 EasyOCR 官方示例
- 完整致谢见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)

## License

MIT
