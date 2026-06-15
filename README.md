# Claude Code 小白友好配置

> 一个普通学生折腾出来的 Claude Code 配置分享——踩过的坑、试过的方案、最后留下来好用的。

## 这为什么会有这个仓库？

Claude Code 刚出来的时候我挺兴奋的，但 Claude API 太贵了，一个月下来光 API 费用就吃不消。后来发现可以用 DeepSeek 的兼容接口，成本降到原来的 1/10 不到，就开始认真折腾配置。

过程中踩了不少坑——MCP 怎么配、模型名怎么映射、Token 怎么省、Agent 怎么写才好用……网上资料零零散散的，组合起来费了不少功夫。最后折腾出来一套自己觉得好用的配置，想着"要是当初有人已经踩过这些坑就好了"，就整理出来分享。

**不是大神配置，就是一个普通学生实践验证过的方案。**

## 适合谁

- 刚接触 Claude Code，不想从零配起
- 想用 DeepSeek API 省钱但不知道怎么配
- 想了解 MCP/Agent/Rules 怎么组合比较好用
- 喜欢看别人踩坑记录而不是官方文档

## 我用了什么

- **模型**：DeepSeek v4 Pro（1M 上下文，带思考模式），用它的 Anthropic 兼容接口
- **价格对比**：Claude Sonnet $3/百万 token → DeepSeek 约 ¥1/百万 token
- **MCP 服务（9 个）**：文件操作 / 浏览器自动化 / GitHub / 数据库 / 文档搜索 / 网页搜索 / 图片识别 / 并行搜索 / 持久化记忆
- **自定义 Agent（9 个）**：代码审查、安全检查、测试驱动、架构设计、构建排错等
- **规则文件（6 个）**：代码质量、安全、测试、工作流、性能、模式——踩坑后总结的
- **权限模式**：`bypassPermissions`（不再每次点 Yes，自动批准）
- **Token 优化**：RTK (Rust Token Killer) 自动精简 Shell 命令，省 60-90% token
- **Agent 技能**：mattpocock/skills 工程化技能包——Issue 跟踪、Triage 分类、领域文档

## 快速开始

```bash
# 1. 注册 DeepSeek 获取 API Key：https://platform.deepseek.com
# 2. 克隆仓库
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter
# 3. 复制到 Claude Code 配置目录
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json
cp templates/settings.local.json.example ~/.claude/settings.local.json
# 4. 编辑 ~/.mcp.json，把文件路径改成你自己的
# 5. 设置环境变量
#    Windows: setx ANTHROPIC_API_KEY "sk-your-key"
#    Mac/Linux: export ANTHROPIC_API_KEY="sk-your-key"
# 6. 重启 Claude Code
```

**详细步骤看 [SETUP.md](SETUP.md)，每一步都写清楚了。不会的提 Issue。**

## 踩坑记录（挑几个印象深的）

1. **缓存命中率低**：加了 `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` 这行环境变量后缓存命中率从 50% 跳到 90%+，每次对话省不少钱
2. **子 Agent 默认用 flash 模型**：早先不知道 `CLAUDE_CODE_SUBAGENT_MODEL` 这个变量，代码审查质量一直上不去，换成 pro 后明显改善
3. **Windows 路径问题**：MCP 的 filesystem 服务器在 Windows 下路径要用双反斜杠 `C:\\Users\\...`
4. **RTK 装完不生效**：要先 `cargo install rtk`，同时注意有个重名包（Rust Type Kit），别装错了
5. **Vision MCP 需要额外 API**：DeepSeek 不支持图片，得搭 mcp-vision + DashScope qwen-vl-max 桥接
6. **GPU 调用踩坑**：PyTorch 装了 CPU 版，RTX 3060 一直用不了。QGIS 自带的 Python 环境 DLL 冲突（c10.dll 1114 错误）。解决：安装独立 Python + `pip install torch --index-url https://download.pytorch.org/whl/cu128`

更多踩坑在 [SETUP.md](SETUP.md) 里。

## 不是什么

- ❌ 不是"最佳实践"——只是我自己试下来好用的
- ❌ 不是"终极配置"——肯定有更好的方案
- ❌ 不是"官方推荐"——跟 Anthropic 和 DeepSeek 都没关系
- ✅ 就是一个普通用户的折腾记录，如果能帮你少走弯路就值了

## 感谢

这个配置方案用到了很多开源项目和社区资源，没有他们就没有这套配置。完整列表在 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)——感谢每一位作者和贡献者！

## 许可证

MIT — 随便用，署名更好。有问题 [提 Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues)。
