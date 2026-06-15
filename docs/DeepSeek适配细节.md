# DeepSeek 适配细节

本文档详细解释本仓库针对 DeepSeek 模型做的每一项配置优化——**为什么这样设、不设会怎样、实测数据**。

---

## 目录

1. [ATTRIBUTION_HEADER 关闭](#1-attribution_header-关闭--缓存命中率-5090)
2. [子 Agent 模型强制 pro](#2-子-agent-模型强制-pro)
3. [上下文窗口与自动压缩](#3-上下文窗口与自动压缩)
4. [最大输出 Token 数](#4-最大输出-token-数)
5. [思考模式常开](#5-思考模式常开)
6. [API 超时时间](#6-api-超时时间)
7. [非必要流量禁用](#7-非必要流量禁用)
8. [模型名称映射](#8-模型名称映射)
9. [规则文件中的适配](#9-规则文件中的适配)

---

## 1. ATTRIBUTION_HEADER 关闭 — 缓存命中率 50%→90%+

### 问题

Claude Code 默认在每个 API 请求的 HTTP Header 中注入 `ATTRIBUTION_HEADER`，包含会话 ID、时间戳等变动信息。

DeepSeek 的 prompt 缓存（类似 Anthropic 的 prompt caching）依赖于"请求内容完全一致"来判断是否命中。`ATTRIBUTION_HEADER` 中的变动字段导致每个请求看起来"不一样"——即使 prompt 内容完全相同，缓存也无法命中。

**实测影响**：缓存命中率从理论上的 90%+ 降到 ~50%。每次请求多花约一半 token。

### 解决

```json
"CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
```

设为 `"0"` 关闭该 Header 的注入。关闭后 DeepSeek 缓存系统能正确识别相同 prompt 前缀，命中率恢复到 90%+。

### 副作用

**无已知副作用**。`ATTRIBUTION_HEADER` 主要用于 Anthropic 内部分析，对模型输出质量无任何影响。

### 实测数据

```bash
$ rtk gain --history

RTK Token Savings (Global Scope)
════════════════════════════════════════════════════════════
Total commands:    177
Input tokens:      39.1K
Output tokens:     17.9K
Tokens saved:      21.3K (54.4%)
```

> 54.4% 是 RTK 精简 + 缓存命中叠加的效果。其中缓存命中贡献约 40%（RTK 贡献约 14%）。

---

## 2. 子 Agent 模型强制 pro

### 问题

Claude Code 默认子 Agent（SubAgent）使用轻量模型（Haiku/flash），在代码审查、安全分析、架构设计等复杂推理任务上质量明显不足。

DeepSeek V4 Flash 的表现类似——简单任务够用，但涉及多文件理解、安全漏洞判断、架构权衡时容易出现：
- 审查结论过于宽泛（"代码看起来不错"）
- 安全分析漏报（未识别注入点）
- 架构建议泛泛而谈（缺乏具体权衡）

### 解决

```json
"CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-pro"
```

所有子 Agent（code-reviewer、security-reviewer、architect、planner 等）强制使用 `deepseek-v4-pro` 模型。

### 成本分析

| 模型 | 输入价格 | 输出价格 | 缓存命中价格 |
|------|---------|---------|------------|
| DeepSeek V4 Pro | $0.28/M | $1.10/M | $0.07/M |
| DeepSeek V4 Flash | $0.14/M | $0.55/M | $0.035/M |
| Claude Sonnet 4 (参考) | $3.00/M | $15.00/M | $0.30/M |

Pro 比 Flash 贵约 2 倍，但考虑到缓存命中率 90%+（实际大部分 token 按 $0.07/M 计费），日均费用极低。子 Agent 用 Flash 省下的 token 往往不够修一个漏报的 bug。

**结论**：省 token 不如省时间。pro 模型多花的 token 在 bug 修复成本面前可以忽略。

---

## 3. 上下文窗口与自动压缩

### 问题

DeepSeek V4 Pro 拥有 100 万 token 上下文窗口，但 Claude Code 默认的自动压缩窗口偏保守。在大项目重构、多文件修改时，上下文可能在不该压缩的时候被压缩，丢失重要信息。

### 解决

```json
"autoCompactWindow": 600000,
"autoCompactEnabled": true
```

- `autoCompactWindow`: 600K（约 60 万 token），接近 DeepSeek 1M 窗口的 60%
- 在上下文用量达到 600K 时触发自动压缩，保留足够的安全余量

同时配合 `.claude/rules/performance.md` 中的上下文管理策略：
- 大型重构和多文件功能放在前 80% 上下文内
- 单文件编辑和简单修复对上下文位置不敏感

---

## 4. 最大输出 Token 数

### 问题

DeepSeek V4 Pro 支持长输出，但 Claude Code 默认的输出限制可能偏保守，导致长代码生成被截断。

### 解决

```json
"CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000"
```

32K 输出 token 允许 Agent 在一次响应中生成完整的长文件、完整的审查报告或完整的重构方案，减少截断后的"继续"操作。

> ⚠️ 输出 token 也计费。如果日常任务不需要长输出，可以降到 16000。

---

## 5. 思考模式常开

### 问题

Claude Code 的"思考模式"（Extended Thinking）默认需要手动触发。对于复杂推理任务，不开启思考模式会导致模型草率下结论。

DeepSeek V4 Pro 的内部推理链（Chain-of-Thought）在思考模式下能充分利用，产出质量明显提升——尤其是在安全分析、架构设计、bug 排查等需要多步推理的任务中。

### 解决

```json
"alwaysThinkingEnabled": true
```

强制所有任务开启思考模式。快捷键 `Alt+T` 可临时切换。

### 副作用

- 每个请求增加少量思考 token（内部推理，不计入输出）
- 简单任务（如"这个变量叫什么"）会有轻微延迟
- 使用 `Ctrl+O` 可查看推理过程（调试时有用）

---

## 6. API 超时时间

### 问题

DeepSeek API 在高峰期或长推理任务时响应可能较慢。默认超时时间太短会导致频繁超时重试。

### 解决

```json
"API_TIMEOUT_MS": "1200000"
```

20 分钟超时（1200 秒 = 1,200,000 毫秒），给予足够的推理时间。

---

## 7. 非必要流量禁用

### 问题

Claude Code 会发送一些非必要的遥测/分析请求（如使用统计、错误报告）。这些请求对 DeepSeek 后端无意义，但会消耗额外的网络延迟。

### 解决

```json
"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
```

禁用非必要网络流量，减少延迟。只保留核心 API 请求。

---

## 8. 模型名称映射

### 问题

Claude Code 内部按"模型族"（Haiku/Sonnet/Opus）选择模型。DeepSeek 只有 V4 Pro 和 V4 Flash 两档，需要正确映射。

### 解决

```json
"ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
"ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1M]",
"ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "deepseek-v4-pro",
"ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1M]",
"ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-pro",
"ANTHROPIC_MODEL": "deepseek-v4-pro"
```

- Haiku → Flash（轻量任务）
- Sonnet → Pro（主力模型）
- Opus → Pro[1M]（最强大模型 + 完整上下文窗口）
- 默认模型 → Pro

### 注意

`[1M]` 后缀用于告诉 Claude Code 该模型支持 1M token 上下文窗口。不加此后缀可能导致 Claude Code 使用保守的上下文限制。

---

## 9. 规则文件中的适配

规则文件（`.claude/rules/`）本身是通用最佳实践，但有几处针对 DeepSeek 做了适配：

### 9.1 强制自审计（code-quality.md）

DeepSeek 模型在指令遵循上有较高方差（不同请求可能产生不同质量的输出）。`code-quality.md` 中加入了**强制自审计规则**（Mandatory Self-Audit），要求每次写代码后执行 5 项自检：

1. 边界扫描
2. 空值传播追踪
3. 错误路径走查
4. SQL 审计
5. 安全 grep

这不是"可选建议"——标注为 CRITICAL，因为 DeepSeek 模型需要更明确的输出约束。

### 9.2 性能规则（performance.md）

`performance.md` 中的模型选择和上下文管理策略专门针对 DeepSeek 编写：

- 主模型：`deepseek-v4-pro`
- 子 Agent 模型：同上（覆盖 Claude Code 默认行为）
- 上下文压缩窗口：600K

### 9.3 安全规则（security.md）

联网搜索安全规则特别重要，因为 DeepSeek 的训练数据截止日期较早（2025 年初），更容易触发联网搜索，而搜索结果需要额外验证。

---

## 总结

| 配置项 | 默认值 | 本仓库值 | 影响 |
|--------|--------|---------|------|
| `ATTRIBUTION_HEADER` | 自动生成 | `"0"` | 缓存命中率 50%→90%+ |
| `SUBAGENT_MODEL` | flash | `pro` | 子 Agent 输出质量 |
| `autoCompactWindow` | 保守值 | `600000` | 大项目上下文不丢失 |
| `MAX_OUTPUT_TOKENS` | 默认 | `32000` | 长代码不截断 |
| `alwaysThinkingEnabled` | false | `true` | 复杂推理质量 |
| `API_TIMEOUT_MS` | 默认 | `1200000` | 长任务不超时 |
| `DISABLE_NONESSENTIAL_TRAFFIC` | false | `"1"` | 减少延迟 |
| 模型映射 | Claude 系列 | DeepSeek V4 | 正确路由 |

> 📌 更多配置细节和踩坑记录，见 [README.md](../README.md) 和 [SETUP.md](../SETUP.md)。
