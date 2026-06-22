# Claude Code Configuration

@RTK.md
@.claude/rules/yagni.md
@.claude/rules/code-quality.md
@.claude/rules/security.md
@.claude/rules/testing.md
@.claude/rules/workflow.md
@.claude/rules/performance.md
@.claude/rules/patterns.md

## Agent skills

### Issue tracker（本地任务追踪）— PROACTIVE TRIGGERS
- User starts a new feature → create `.scratch/<feature-slug>/PRD.md`（需求文档）
- User reports a bug/problem → create `.scratch/<feature-slug>/issues/01-<slug>.md` with `Status: needs-triage`（问题工单）
- User asks "what's the status" → read and summarize issue files（汇总进度）
- See `docs/agents/issue-tracker.md` for conventions

### Triage labels（问题分类标签）
Default vocabulary: `needs-triage`（待分类）, `needs-info`（缺信息）, `ready-for-agent`（AI可处理）, `ready-for-human`（需人工）, `wontfix`（不修）。
- When creating an issue, ALWAYS add a `Status:` line
- When the user clarifies requirements, update the status accordingly
- See `docs/agents/triage-labels.md` for role mapping

### Domain docs（项目领域知识文档）
- Before working in a project, check for `CONTEXT.md`（项目知识库）— read it if exists
- If project is complex and missing `CONTEXT.md`, suggest `/grill-with-docs`（领域文档生成器）
- When you see unfamiliar terms, check `CONTEXT.md` glossary first
- See `docs/agents/domain.md` for conventions
