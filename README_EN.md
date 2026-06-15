# Claude Code + DeepSeek: The Missing Config Layer

> **A project scaffolding toolkit built specifically for Claude Code CLI + DeepSeek API users.** Clone → init.sh → Work. Every feature solves a pain point we actually hit.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](#)
[![Model: DeepSeek_v4_Pro](https://img.shields.io/badge/Model-DeepSeek_v4_Pro-green.svg)](#)
[![RTK: 55%_Token_Savings](https://img.shields.io/badge/RTK-55%25_Token_Savings-purple.svg)](#)
[![Claude_Code_CLI](https://img.shields.io/badge/Tool-Claude_Code_CLI-orange.svg)](#)
[![DeepSeek_API](https://img.shields.io/badge/Backend-DeepSeek_API-blue.svg)](#)

[中文 README](README.md) · [Setup Guide (Chinese)](SETUP.md) · [DeepSeek Optimization Details (Chinese)](docs/DeepSeek适配细节.md)

---

> ⚠️ **Important — Read Before Using**
>
> **1. This repo handles project-level config only (CLAUDE.md / commands / Agent templates)**
> — It does NOT handle API-level routing. Connecting Claude Code to DeepSeek requires DeepSeek's official `/anthropic` compatibility endpoint — you must configure your global `~/.claude/settings.json` and environment variables yourself. **This tool will NOT auto-fill your API key or BaseURL.**
>
> **2. The ONLY supported setup: Claude Code CLI + DeepSeek API**
> — ❌ NOT compatible with: Claude web app, Cursor, Roo Code, aider, Ollama local models. These tools use entirely different config formats.
>
> **3. All configs are tuned for DeepSeek model behavior**
> — Claude-specific features that interfere with DeepSeek are disabled (ATTRIBUTION_HEADER), sub-agents are forced to the pro model, cache hit rate is optimized to 90%+, and rule files include DeepSeek-specific adaptation notes. This is NOT a generic "Claude Code template."

---

## Three-Layer Architecture: Who Does What

```
┌──────────────────────────────────────────────────┐
│         This Repo (Config & Tooling Layer)         │
│  MCP Services · Custom Agents · Rules · Hooks      │
│  RTK Token Savings · Auto-Backup · OCR             │
│  → Problems here? File an Issue                    │
├──────────────────────────────────────────────────┤
│         Claude Code CLI (Tool Layer)               │
│  Agent Loop · Tool Calling · Permissions · UI      │
│  → Maintained by Anthropic. Not our scope.         │
├──────────────────────────────────────────────────┤
│          DeepSeek API (Model Layer)                │
│  LLM Inference · Prompt Cache · Token Billing      │
│  → Provided by DeepSeek. We only adapt configs.    │
└──────────────────────────────────────────────────┘
```

| Symptom | Which Layer | Where to Look |
|---------|------------|---------------|
| CLI hangs, tool call errors | Claude Code CLI | [anthropics/claude-code](https://github.com/anthropics/claude-code) |
| Poor model output, API 500s | DeepSeek API | [platform.deepseek.com](https://platform.deepseek.com) |
| MCP won't start, Agent broken | This repo's config | [File an Issue](https://github.com/YuhaoLin2005/claude-code-starter/issues) |

---

## Is This For You?

**✅ This repo is for you if:**

- You use **Claude Code CLI** — the `claude` command in a terminal. Not a VSCode extension. Not a web app. Not an API SDK.
- You use **DeepSeek API** as your LLM backend (cost-effectiveness, not desperation)
- You're on **Windows** (Mac/Linux works too, but you'll need to tweak paths)
- You want to skip the zero-to-one grind of MCP/Agent/Rules configuration
- You care about token costs and want 90%+ cache hit rates

**❌ This repo is NOT for you if:**

- You use **Cursor / Copilot / Windsurf / Trae** or any IDE plugin (those are entirely different tools)
- You use **Anthropic's official API** instead of DeepSeek (the cache fix won't apply)
- You expect **one-click, zero-config** setup (you'll need to edit paths in `~/.mcp.json` — this is CLI tooling, not SaaS)
- You want the "best" setup (this is the "battle-tested, definitely works" setup)
- You're on a **headless Linux server** (Playwright MCP needs a browser; not configured for headless)

---

## Five Problems This Solves

### ① DeepSeek Cache Hit Rate Stuck at ~50%

**Root cause**: Claude Code injects an `ATTRIBUTION_HEADER` (session ID + timestamp) into every request. DeepSeek's prompt cache sees these as different requests → half your tokens are wasted.

**The fix**: Set `CLAUDE_CODE_ATTRIBUTION_HEADER="0"`. Cache hit rate jumps from **~50% → 90%+**. Every request costs half as much.

```bash
# Real numbers (RTK + cache hit rate combined)
$ rtk gain --history
Tokens saved: 21.3K (54.4%)
```

### ② Zero-to-Productive Takes Days, Not Minutes

Fresh `npm install -g @anthropic-ai/claude-code` gives you a bare CLI. No MCP services. No custom agents. No rules. Everyone wastes the same days reinventing the same wheel.

**What's here**: 8 MCP services, 9 custom agents, 6 rule files — all configured, tested, and mutually compatible. **Clone → init.sh → Work.**

### ③ No Undo When AI Messes Up

AI edits are probabilistic. Without backups, every change is a gamble.

**Three-layer automatic backup**:

| Layer | Mechanism | When |
|-------|----------|------|
| File-level | PreToolUse Hook: auto-copy to `.claude/backups/` before every Edit/Write (keeps last 5) | Before every edit |
| Session-level | SessionStart Hook: auto `git commit` all uncommitted changes | Every session start |
| Manual | `git reset --hard HEAD~1` — instant rollback | Anytime |

### ④ Tokens Burned on Shell Output

`git status`, `npm install`, `ls -la` — full command output is piped to the model and billed as input tokens, even though most of it is noise to the AI.

**The fix**: RTK (Rust Token Killer) intelligently strips shell output to what the AI actually needs. **Measured: 55% token savings**.

### ⑤ "How Much Does the Model Still Remember?" — Real-Time Compression Counter

**Problem**: During long sessions, Claude Code auto-compacts context. Each compaction turns early conversation into summaries — the model no longer has full context, relying instead on chains of summaries. The more compactions, the worse the "memory degradation." But users have no idea how many times it's happened.

**Solution**: `statusline.py` shows **session compression count** instead of cost (you already know your API pricing). It tracks `total_input_tokens / 600K`.

| Compressions | Status Line | Meaning |
|-------------|------------|---------|
| 0 | 🟢 Fresh memory | Full context, remembers everything |
| 1-2 | 🟢 Compacted ×N | Early content summarized, normal range |
| 3-4 | 🟡 Compacted ×N ⚠ | Multiple summary layers, details may be lost |
| 5+ | 🔴 Compacted ×N 🔥 Start new session | Model relies entirely on summary chains, high hallucination risk |

> 🎯 **Works with ALL models.** This tracks Claude Code's own context compaction behavior — it's independent of model pricing or provider. Whether your backend is DeepSeek, Anthropic, or OpenAI-compatible, the counter increases every time Claude Code auto-compacts. **All Claude Code CLI users can use this.**

---

## Core Differences: Generic Template vs. This Repo

| Dimension | Generic Claude Code Template | **This Repo** |
|-----------|----------------------------|---------------|
| Model Tuning | Claude series (Haiku/Sonnet/Opus) | **DeepSeek V4 Pro/Coder**, Claude-specific interference disabled |
| Cache Hit Rate | ~50% (ATTRIBUTION_HEADER interference) | **90%+** (fixed) |
| Sub-agent Model | flash (weak on complex tasks) | **Forced pro model** |
| Tool Calling | Optimized for Claude Opus thinking | **Optimized for DeepSeek multi-turn calls** |
| Strengths | General frontend, copywriting, full-stack | Full-stack + **math reasoning + batch refactoring + data modeling** |
| MCP Services | 0 (DIY) | **8**, ready to go |
| Custom Agents | Built-in defaults | **9** specialized (review/security/TDD/architecture/build/Rust…) |
| Auto-Backup | ❌ None | **3 layers** (file + session + manual) |
| Token Optimization | ❌ None | **RTK: 55% savings** |
| Status Line | Shows cost only (known info) | **Real-time compression count** (memory degradation warning, model-agnostic) |
| Scene Templates | Generic | **Frontend / Backend / Math-Algorithm** 3 presets |
| Setup | Manual `cp` | **./init.sh interactive one-command setup** |
| Time to Productive | Days (trial and error) | **~2 minutes** (init.sh) |

---

## Prerequisite: API Configuration (Must Do First)

Claude Code connects to DeepSeek via DeepSeek's official `/anthropic` compatibility endpoint. **The following config is NOT part of this repo's scope — you must set it up manually before using our templates.**

<details>
<summary>Click to expand: Complete <code>~/.claude/settings.json</code> (copy & paste)</summary>

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-deepseek-api-key",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1M]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1M]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-pro",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-pro",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "API_TIMEOUT_MS": "1200000"
  },
  "autoCompactEnabled": true,
  "autoCompactWindow": 600000,
  "alwaysThinkingEnabled": true,
  "fileCheckpointingEnabled": true,
  "showTurnDuration": true,
  "todoFeatureEnabled": true,
  "includeCoAuthoredBy": false,
  "theme": "dark"
}
```

> 💡 **Key notes**:
> - Replace `ANTHROPIC_AUTH_TOKEN` with your DeepSeek API Key (get one at [platform.deepseek.com](https://platform.deepseek.com))
> - `CLAUDE_CODE_ATTRIBUTION_HEADER="0"` is critical — boosts cache hit rate from 50% to 90%+
> - `CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-pro"` forces all sub-agents to use the main model
> - This config relies on DeepSeek's official compatibility layer — not part of this repo's functionality

</details>

---

## Quick Start

### 🚀 One-Command Init (Recommended)

```bash
# 1. Configure global settings.json (see "Prerequisite" above)
# 2. Clone and run the init script
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter
./init.sh
```

The script auto-detects your DeepSeek config → interactively selects project type → copies all files → prints a completion checklist.

### Manual Setup

```bash
git clone https://github.com/YuhaoLin2005/claude-code-starter.git
cd claude-code-starter
cp -r .claude/* ~/.claude/
cp templates/mcp.json.example ~/.mcp.json
# Edit ~/.mcp.json → update filesystem paths
```

### Staying Updated

```bash
# Inside the repo directory
./update.sh

# Or remote one-liner
curl -sL https://raw.githubusercontent.com/YuhaoLin2005/claude-code-starter/main/update.sh | bash
```

> 📖 **Stuck?** See the [detailed setup guide (Chinese)](SETUP.md) with screenshots for every step.
>
> ⚠️ **RTK is optional** — everything works without it. It saves ~55% on shell output tokens. Install: see [SETUP.md Step 5](SETUP.md#step-5安装-rtk可选推荐).
>
> 📂 **Scene templates**: `templates/frontend/` · `templates/backend/` · `templates/math-alg/` — pick what fits your project.

---

## What's Inside

| Category | Contents |
|----------|---------|
| 🧩 **MCP Services** (8) | Filesystem · Playwright Browser · GitHub API · PostgreSQL · Context7 Docs · DuckDuckGo Search · Parallel Multi-Engine Search · Squish Persistent Memory |
| 🤖 **Custom Agents** (9) | Code Review · Security Audit · TDD Guide · Architecture Design · Build Debugger · Code Simplifier · Docs Updater · Rust Reviewer · Senior Dev |
| 📋 **Rule Files** (6) | Code Quality · Security · Testing · Workflow · Performance · Design Patterns |
| 📂 **Scene Templates** (3) | Frontend · Backend · Math/Algorithm |
| 🛡️ **Auto-Backup** (3 layers) | PreToolUse file snapshots · SessionStart git commit · Manual git reset |
| ⚡ **Token Optimization** | RTK shell output stripping (measured 55%) · Cache hit rate fix (50%→90%+) · Sub-agent pro model · Status line compression counter (model-agnostic) |
| 📊 **Status Line** | Real-time compression tracker — tells you how much the model remembers and when to start a fresh session |
| 🔍 **Local OCR** | EasyOCR offline screenshot recognition — DeepSeek can't handle images, this bridges the gap |
| 🔒 **Secret Scanning** | `/desensitize` command — scan for keys, paths, internal IPs before pushing (4 severity levels, allowlist support) |
| 🚀 **One-Click Scripts** | `init.sh` interactive setup · `update.sh` one-click rule sync |
| ⌨️ **Keybindings** | `Alt+T` toggle thinking mode · `Ctrl+O` view reasoning trace |

---

## 📸 Screenshots

| RTK Token Savings (55%) | Custom Agents (9) |
|:---:|:---:|
| ![RTK Gain](screenshots/02-rtk-gain.png) | ![Agents](screenshots/03-agents.png) |

---

## Design Decisions

Answers to questions you might have:

**Why not store API keys in `settings.local.json`?**
→ Environment variables have a single source of truth. `settings.local.json` in your home directory is one `git add -A` away from being accidentally committed.

**Why force the pro model for sub-agents?**
→ DeepSeek's flash model produces noticeably worse output on complex reasoning tasks (code review, security analysis). The tokens you save aren't worth the bugs you ship.

**Why hooks instead of cron for auto-backup?**
→ Hooks fire inside the Claude Code process, triggered by actual Edit/Write events. Cron is time-based — it won't save you if things break mid-session.

**Why EasyOCR over mcp-vision?**
→ mcp-vision depends on the DashScope API (unstable auth, requires internet). EasyOCR runs locally, no API key, 85%+ accuracy on Chinese text. Good enough.

**Why `~/.claude/` instead of per-project `.claude/`?**
→ Rules, agents, and habits are user-level concerns. Cloning configs into every project is wasteful and leads to version fragmentation.

**Why show compression count instead of cost in the status line?**
→ Cost is known information — you know which API you're paying for. Compression count is the unknown: nobody can tell how many times Claude Code has silently compacted context. Each compaction turns early conversation into summaries, and the model degrades from "remembers everything" to "reasoning from summary chains." After 5+ compactions, hallucination risk spikes — but without the counter, you'd never know you're in the danger zone. **This feature works for ALL model backends**, not just DeepSeek.

---

## FAQ

### Q1: Will cloning this repo instantly connect Claude Code to DeepSeek?

**No.** The API-level connection relies on DeepSeek's official `/anthropic` compatibility endpoint. You must manually configure `ANTHROPIC_BASE_URL` and your API Key in `~/.claude/settings.json` (see "Prerequisite" section above). This repo handles everything *after* the connection — MCP services, agents, rules, backups, token optimization. Running `./init.sh` helps detect missing config.

### Q2: Can I use these rules with Cursor / Roo Code / aider?

**No.** This repo's agent definitions, slash commands, and hooks are all based on Claude Code CLI's proprietary format. Other tools use completely different config systems — the rules won't load and won't work. If you use Cursor or Copilot, this repo is not for you.

### Q3: Does this support locally deployed DeepSeek models via Ollama?

**Not currently.** All configs are tuned for DeepSeek's official cloud API (`api.deepseek.com`). Ollama's local deployment has different API formats, caching behavior, and model characteristics — none of which have been tested or adapted here.

### Q4: Does this work on Mac / Linux?

**Mostly yes, with tweaks needed.** MCP filesystem paths, RTK hook paths, and Python script paths use Windows conventions. Mac/Linux users comfortable with CLI configuration can adapt these — but the repo has only been fully tested on Windows.

### Q5: Is RTK required? What happens if I skip it?

**Not required.** RTK is optional — all features (MCP, agents, backups, rules) work without it. Installing it adds automatic shell output optimization, saving ~55% on tokens from command output. Install instructions: [SETUP.md Step 5](SETUP.md#step-5安装-rtk可选推荐).

### Q6: Won't forcing pro model for all sub-agents get expensive?

**No.** DeepSeek V4 Pro costs ~1/15 to 1/20 of Claude Sonnet 4 ($0.28/M input vs $3/M, $1.10/M output vs $15/M). With 90%+ cache hit rates and RTK saving 55% on shell tokens, actual daily cost is well under a dollar for typical usage. The tokens saved by using flash model aren't worth the bugs it introduces.

### Q7: Is the compression count on the status line accurate?

**Yes.** Compression count = `total_input_tokens / autoCompactWindow(600K)`, read directly from Claude Code's JSON stdin. No external API calls, no estimation — the number increments by 1 each time auto-compact fires. **All Claude Code CLI users**, regardless of model backend, can use this. Configure via the `statusLine` field in settings.json.

### Q8: What can I do besides starting a new session when compression gets high?

**You can manually trigger compact or reduce context usage** — try `/compact`, load fewer files at once, disable MCP services you don't need. But the most effective solution is starting a fresh session so the model regains full context.

---

## Lessons Learned

Things that cost me hours. May save you some:

- **Sub-agent quality** — Default uses flash model for sub-tasks. Set `CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-pro`.
- **Cache hit rate (the WHY)** — `ATTRIBUTION_HEADER` carries session ID + timestamp. DeepSeek cache sees them as distinct requests. Set to `"0"` → 50%→90%+.
- **Status line compression counter** — More useful than cost display: tells you how much the model still remembers. 5+ compactions = start a new session.
- **Long context** — `autoCompactWindow=600K` + `CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000` + `alwaysThinkingEnabled=true`.
- **Windows MCP paths** — Double backslashes: `C:\\Users\\...`, or JSON parsing fails.
- **RTK name collision** — crates.io has `reachingforthejack/rtk` (Rust Type Kit). You want the `rtk` package.
- **Screenshot OCR** — DeepSeek can't do vision. EasyOCR runs offline, no API key. Script: `.claude/scripts/ocr.py`.
- **PyTorch GPU on Windows** — QGIS's bundled Python has DLL conflicts (`c10.dll 1114`). Use standalone Python.

---

## Roadmap

- [x] `init.sh` — interactive one-command setup (auto-detect config + scene selection)
- [x] `update.sh` — one-click sync latest rule templates
- [x] `statusline.py` — compression counter status line (model-agnostic, all Claude Code CLI users)
- [ ] More tech stack templates (Java/Spring, Go, Rust)
- [ ] DeepSeek new model adaptation tracking

PRs welcome!

---

## Acknowledgments

Standing on the shoulders of many open-source projects and community contributors. Full list in [ATTRIBUTIONS.md](ATTRIBUTIONS.md).

## License

MIT
