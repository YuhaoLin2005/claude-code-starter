# Development Workflow

## 🛡️ AUTO-BACKUP (Recommended Safety Net)

> Before modifying files, ensure you can roll back. Git is the cheapest insurance.

**Before ANY Write/Edit operation:**
1. Check if project is a git repo → `git status`
2. If NOT → `git init && git add -A && git commit -m "chore: initial backup"`
3. If dirty → `git add -A && git commit -m "chore: pre-task snapshot — <what you're about to do>"`
4. After each significant change → commit with descriptive message

**Rollback:** `git reset --hard HEAD~1` reverts the last change.

## Feature Implementation Pipeline

**0. Research & Reuse** (mandatory before new implementation)
- Search GitHub (`gh search code/repos`), npm/PyPI/crates.io for existing solutions
- Check library docs via Context7 or vendor docs
- Prefer battle-tested libraries and adaptable open-source implementations
- Port/wrap proven approaches over writing net-new code when it meets requirements

**1. Plan First** — Use **planner** agent; identify dependencies, risks, break into phases

**2. TDD** — Use **tdd-guide** agent; write tests first, implement to pass, verify 80%+

**3. Code Review** — Use **code-reviewer** agent immediately after writing code; address CRITICAL/HIGH issues

**3.5. Self-Check** — Complex logic first via **senior-dev** agent (self-reviews before output); then **code-reviewer** validates. Don't wait until the feature is complete — review incrementally per file/module.

**4. Commit & Push** — Detailed messages, conventional commits format

**5. Pre-Review Checks** — CI/CD passing, merge conflicts resolved, branch up to date

## Agent Usage

Available agents in `~/.claude/agents/`: **senior-dev**, **planner**, **architect**, **tdd-guide**, **code-reviewer**, **security-reviewer**, **build-error-resolver**, **doc-updater**, **rust-reviewer**

No user prompt needed:
- Complex implementation → **senior-dev** | Complex features → **planner**
- Architectural decisions → **architect** | Code just written → **code-reviewer**
- Bug fix / new feature → **tdd-guide**
- Security-sensitive code → **security-reviewer** | Build fails → **build-error-resolver**

ALWAYS use parallel execution for independent tasks. For complex problems, use split-role sub-agents (senior engineer, security expert, consistency reviewer).

## Proactive Skill Triggers (CRITICAL)

User won't remember to invoke skills manually. You MUST proactively suggest the right skill when you detect these situations. All suggestions MUST be in Chinese so the user understands what each skill does.

| 你遇到的情况 | 应该建议的技能 | 用这句中文问用户 |
|-----------|-----------------|--------|
| 用户描述新功能或新领域概念 | `/grill-with-docs`（领域文档生成器） | "要不要先用领域文档生成器把相关知识沉淀下来？后续AI就能自动理解这个项目了。" |
| 用户报 bug 或描述问题 | `/triage`（问题分类器） | "先用问题分类器整理一下？会自动打标签、判断优先级。" |
| 准备开始写代码实现功能 | `/tdd`（测试驱动开发向导） | "用TDD流程来做？先写测试再实现，保证代码质量。" |
| 大的需求文档需要拆解 | `/to-issues`（需求拆解器） | "这个需求挺大的，拆成小任务逐个实现？更清晰也更好追踪。" |
| 问题描述模糊、需要理清 | `/diagnose`（问题诊断器） | "问题还不明确，用诊断器深入分析一下根因？" |
| 跨多个系统或架构级改动 | `/zoom-out`（架构视角切换） | "涉及多个系统，先切换到架构视角看看整体影响？" |
| 需要快速验证一个想法 | `/prototype`（原型快速构建） | "先快速做个原型验证可行性？不用写完整代码。" |
| 项目缺少领域知识文档 | 建议创建 `CONTEXT.md` | "这个项目还没有领域知识文档，建一个方便后续AI理解？" |
| 新方案与现有架构决策冲突 | 按 domain.md 规则标注冲突 | 明确标注："与 ADR-XXXX 冲突——但值得重新讨论因为……" |

## Agent Skills — Domain Docs

Before exploring unfamiliar projects:
1. Check for `CONTEXT.md` at repo root — read it first
2. Check `docs/adr/` for relevant architectural decisions
3. If both missing and project is complex, suggest `/grill-with-docs`（领域文档生成器）
4. When naming concepts, use the glossary from CONTEXT.md — don't invent synonyms

## Git

**Commit format:** `<type>: <description>` — types: feat, fix, refactor, docs, test, chore, perf, ci

**PR workflow:** Analyze full commit history → `git diff base...HEAD` → draft PR summary with test plan → push with `-u` if new branch
