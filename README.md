# Claude Code × DeepSeek：月付十块钱的 AI 编程完全体

> 9 个 MCP · 9 个 Agent · 零确认弹窗 · RTK 省 70% Token · Windows 开箱即用

不是"最佳实践"，不是"终极配置"——就是一个普通学生真金白银踩坑后折腾出来的方案。如果你也用 Claude Code + DeepSeek，这套配置能让你少踩 80% 的坑。

---

## 省流：你得到什么

| 类别 | 内容 | 痛点解决 |
|------|------|---------|
| 💰 **成本** | DeepSeek v4 Pro，¥1/百万 token | Claude API 涨价？不存在的 |
| 🔧 **MCP × 9** | 文件/GitHub/浏览器/数据库/文档/搜索/图片/并行搜索/记忆 | 不用一个个去 npm 找包了 |
| 🤖 **Agent × 9** | 代码审查、安全检查、TDD、架构、排错、Rust…… | 写完代码自动审，不用手动调 |
| ✅ **零确认** | `bypassPermissions` 自动批准 | 每次操作点 Yes 的日子结束了 |
| ⚡ **省 Token** | RTK 自动精简 Shell 命令 60-90% | 不知不觉省出来的额度 |
| 🧠 **主动 AI** | 技能在正确时机用中文提醒你 | 不会用到一半忘了有什么工具 |
| 📋 **规则 × 6** | 代码质量/安全/测试/工作流/性能/模式 | 代码写出来就像有人审过一轮 |
| 🎮 **GPU** | RTX 3060 + PyTorch CUDA 128 | QGIS Python 冲突的坑也帮你踩过了 |

---

## 为什么会有这个仓库

Claude Code 刚出的时候我兴奋地冲了 Claude API —— 一个月下来账单让我沉默了。

后来发现 DeepSeek 有 Anthropic 兼容接口，价格只有 Claude 的 1/10，就开始了漫长折腾。网上资料零散，很多教程互相矛盾，光是"子 Agent 为什么质量这么差"就查了一下午（答案是默认用 flash 模型）。

踩了上百个坑之后，终于攒出来一套自己满意的配置。想着 "要是当初有人整理好这些就好了"，就有了这个仓库。

---

## 快速开始

```bash
# 1. 注册 DeepSeek → https://platform.deepseek.com
# 2. 克隆
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter
# 3. 复制配置
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json
cp templates/settings.local.json.example ~/.claude/settings.local.json
# 4. 改路径 → 编辑 ~/.mcp.json 把文件路径改成你自己的
# 5. 设环境变量
#    Windows: setx ANTHROPIC_API_KEY "sk-your-deepseek-key"
#    Mac/Linux: export ANTHROPIC_API_KEY="sk-your-deepseek-key"
# 6. 重启 Claude Code
```

📖 **[详细设置指南（每一步都有截图级说明）](SETUP.md)** · 搞不定？[提 Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues)

---

## 精选踩坑（省你几个小时）

1. **缓存从 50% → 90%+**：加 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"`，每次对话多省几毛，积少成多
2. **子 Agent 质量差**：默认走 flash 模型！设 `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro` 解决
3. **Windows MCP 路径**：filesystem 服务器路径写 `C:\\Users\\...` 双反斜杠，少一个都不行
4. **RTK 不生效**：`cargo install rtk` 别装成 Rust Type Kit（同名不同作者）
5. **图片识别**：DeepSeek 原生不支持图片，搭 mcp-vision + DashScope qwen-vl-max 桥接
6. **PyTorch GPU**：QGIS 自带 Python 的 DLL 会冲突（c10.dll 1114）→ 装独立 Python 解决

---

## 不是什么

- ❌ 不是"最佳实践"——只是我自己试下来好用的
- ❌ 不是"终极配置"——社区里肯定有更好的方案
- ❌ 不是"官方推荐"——跟 Anthropic 和 DeepSeek 都没关系
- ✅ 就是一个普通学生实践验证过的方案，能让你少走弯路

---

## 感谢

站在巨人的肩膀上。完整致谢：[ATTRIBUTIONS.md](ATTRIBUTIONS.md)

## 许可证

MIT — 随便用，署名更好。
