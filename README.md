# deepseek-claude-code-starter

Claude Code + DeepSeek 组合的脚本和配置集——让 DeepSeek 在 Claude Code 中发挥出接近原生的体验。

## 核心优化

- **🧠 模型分流**：主 Agent 用 Pro 做深度推理，子 Agent 用 Flash 处理读文件/搜索/测试等杂活。
- **🦥 YAGNI 懒人法则**：6级决策阶梯——标准库能做的不用写、一行搞定的不用写五十行。
- **📦 一键部署**：`./init.sh` 自动检测环境、交互式选择组件、符号链接到 `~/.claude/`。
- **🔄 自动备份**：每次修改前备份文件（保留最近 5 份）+ 会话启动自动 git commit。
- **🛡️ 安全阻断**：PreToolUse hook 自动拦截敏感文件访问和危险命令。
- **🔍 搜索补强**：DuckDuckGo MCP 补足 DeepSeek 训练数据时效。
- **👁️ 本地 OCR**：RapidOCR 离线识别截图（ONNX，GPU可选），让 DeepSeek 能"看懂"图片。
- **📊 状态行**：显示上下文压缩次数，压缩 5+ 次提醒新开会话。
- **🎨 自动格式化**：Edit/Write 后自动 prettier 格式化前端文件（可选）。

## 目录结构

```
.claude/
├── agents/       # 自定义 Agent（代码审查、安全、TDD 等）
├── rules/        # 规则文件（代码质量、安全、测试、YAGNI 等）
├── scripts/      # 脚本（安全阻断、自动格式化、OCR、状态行、备份等）
├── skills/       # 自定义技能
└── commands/     # 斜杠命令
init.sh           # 一键初始化
update.sh         # 一键更新
```

## 依赖

- DeepSeek API Key
- RapidOCR（`pip install rapidocr-onnxruntime onnxruntime-gpu`，本地 OCR）
- Git（自动备份依赖）
- DuckDuckGo MCP server（搜索功能）

## 安装

```bash
git clone https://github.com/YuhaoLin2005/deepseek-claude-code-starter.git
cd deepseek-claude-code-starter
./init.sh
```

## 已知局限

- OCR 速度取决于本地硬件
- 主要在 Windows 上验证，Mac/Linux 需自行调整路径
- 需自行配置 API Key 和 base URL

## 相关项目

- [compact-counter-concept](https://github.com/YuhaoLin2005/compact-counter-concept) — 压缩次数监控，上下文压缩非线性效应研究
- [delivery-gate](https://github.com/YuhaoLin2005/delivery-gate) — Claude Code 语义质量 Stop hook（4轮bot review，ECC-approved）

## 参考与致谢

- YAGNI 决策阶梯融合自 [ponytail](https://github.com/DietrichGebert/ponytail)（MIT）
- OCR: [RapidOCR](https://github.com/RapidAI/RapidOCR)（Apache 2.0）
- 完整致谢见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)

## License

MIT
