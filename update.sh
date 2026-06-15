#!/usr/bin/env bash
# ============================================================
# update.sh — 一键同步最新 DeepSeek 适配规则
# ============================================================
# 用法:
#   curl -sL https://raw.githubusercontent.com/YuhaoLin2005/claude-code-starter/main/update.sh | bash
# ============================================================
set -e

RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; BOLD='\033[1m'; RESET='\033[0m'
pass() { echo -e "   ${GREEN}✅ $1${RESET}"; }
skip() { echo -e "   ${YELLOW}⏭️  $1${RESET}"; }
info() { echo -e "   ℹ️  $1${RESET}"; }

echo -e "${BOLD}🔄 同步最新 DeepSeek 适配规则...${RESET}\n"

CLAUDE_HOME="${HOME}/.claude"
TMP_DIR="/tmp/claude-code-starter-update-$$"

# ── 拉取最新仓库 ────────────────────────────────────────────
info "拉取最新规则模板..."
git clone --depth 1 https://github.com/YuhaoLin2005/claude-code-starter.git "$TMP_DIR" 2>/dev/null || {
    echo -e "   ${RED}❌ 拉取失败，请检查网络连接${RESET}"
    exit 1
}

UPDATED=0

# ── 更新规则文件 ────────────────────────────────────────────
echo ""
info "更新规则文件..."
for f in "$TMP_DIR/.claude/rules/"*.md; do
    name=$(basename "$f")
    if [ -f "$CLAUDE_HOME/rules/$name" ]; then
        if ! cmp -s "$f" "$CLAUDE_HOME/rules/$name"; then
            cp "$f" "$CLAUDE_HOME/rules/$name"
            pass "更新: $name"
            UPDATED=$((UPDATED + 1))
        else
            skip "不变: $name"
        fi
    else
        cp "$f" "$CLAUDE_HOME/rules/$name"
        pass "新增: $name"
        UPDATED=$((UPDATED + 1))
    fi
done

# ── 更新 Agent 定义 ─────────────────────────────────────────
echo ""
info "更新 Agent 定义..."
for f in "$TMP_DIR/.claude/agents/"*.md; do
    name=$(basename "$f")
    if [ -f "$CLAUDE_HOME/agents/$name" ]; then
        if ! cmp -s "$f" "$CLAUDE_HOME/agents/$name"; then
            cp "$f" "$CLAUDE_HOME/agents/$name"
            pass "更新: $name"
            UPDATED=$((UPDATED + 1))
        else
            skip "不变: $name"
        fi
    else
        cp "$f" "$CLAUDE_HOME/agents/$name"
        pass "新增: $name"
        UPDATED=$((UPDATED + 1))
    fi
done

# ── 更新命令 ────────────────────────────────────────────────
echo ""
info "更新斜杠命令..."
for f in "$TMP_DIR/.claude/commands/"*.md; do
    name=$(basename "$f")
    if [ -f "$CLAUDE_HOME/commands/$name" ]; then
        if ! cmp -s "$f" "$CLAUDE_HOME/commands/$name"; then
            cp "$f" "$CLAUDE_HOME/commands/$name"
            pass "更新: $name"
            UPDATED=$((UPDATED + 1))
        else
            skip "不变: $name"
        fi
    else
        cp "$f" "$CLAUDE_HOME/commands/$name"
        pass "新增: $name"
        UPDATED=$((UPDATED + 1))
    fi
done

# ── 更新脚本 ────────────────────────────────────────────────
echo ""
info "更新 Python 脚本..."
for f in "$TMP_DIR/.claude/scripts/"*.py; do
    [ ! -f "$f" ] && continue
    name=$(basename "$f")
    if [ -f "$CLAUDE_HOME/scripts/$name" ]; then
        if ! cmp -s "$f" "$CLAUDE_HOME/scripts/$name"; then
            cp "$f" "$CLAUDE_HOME/scripts/$name"
            pass "更新: $name"
            UPDATED=$((UPDATED + 1))
        else
            skip "不变: $name"
        fi
    else
        cp "$f" "$CLAUDE_HOME/scripts/$name"
        pass "新增: $name"
        UPDATED=$((UPDATED + 1))
    fi
done

# ── 更新 CLAUDE.md（仅当用户未自定义） ───────────────────────
echo ""
info "检查 CLAUDE.md..."
if [ -f "$CLAUDE_HOME/CLAUDE.md" ]; then
    if cmp -s "$TMP_DIR/.claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" 2>/dev/null; then
        skip "CLAUDE.md 已是最新"
    elif grep -q "THIS FILE IS CUSTOMIZED" "$CLAUDE_HOME/CLAUDE.md" 2>/dev/null; then
        skip "CLAUDE.md 已自定义，跳过（如需更新请手动对比）"
    else
        skip "CLAUDE.md 可能已自定义，跳过（如需覆盖请手动操作）"
    fi
else
    cp "$TMP_DIR/.claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
    pass "新增: CLAUDE.md"
    UPDATED=$((UPDATED + 1))
fi

# ── 更新 RTK.md ─────────────────────────────────────────────
if [ -f "$CLAUDE_HOME/RTK.md" ]; then
    if ! cmp -s "$TMP_DIR/.claude/RTK.md" "$CLAUDE_HOME/RTK.md"; then
        cp "$TMP_DIR/.claude/RTK.md" "$CLAUDE_HOME/RTK.md"
        pass "更新: RTK.md"
        UPDATED=$((UPDATED + 1))
    else
        skip "RTK.md 已是最新"
    fi
fi

# ── 更新 statusline.py ──────────────────────────────────────
if [ -f "$TMP_DIR/.claude/scripts/statusline.py" ]; then
    if [ -f "$CLAUDE_HOME/scripts/statusline.py" ]; then
        if ! cmp -s "$TMP_DIR/.claude/scripts/statusline.py" "$CLAUDE_HOME/scripts/statusline.py"; then
            cp "$TMP_DIR/.claude/scripts/statusline.py" "$CLAUDE_HOME/scripts/statusline.py"
            pass "更新: statusline.py (状态行定价校准)"
            UPDATED=$((UPDATED + 1))
        else
            skip "statusline.py 已是最新"
        fi
    else
        mkdir -p "$CLAUDE_HOME/scripts"
        cp "$TMP_DIR/.claude/scripts/statusline.py" "$CLAUDE_HOME/scripts/statusline.py"
        pass "新增: statusline.py (状态行定价校准)"
        UPDATED=$((UPDATED + 1))
    fi
fi

# ── 重要：跳过 settings.json ────────────────────────────────
echo ""
info "跳过 ~/.claude/settings.json（包含你的 API Key，不自动覆盖）"
if ! cmp -s "$TMP_DIR/.claude/settings.json" "$CLAUDE_HOME/settings.json" 2>/dev/null; then
    info "仓库 settings.json 有更新，请手动对比:"
    info "  仓库最新: $TMP_DIR/.claude/settings.json"
    info "  你的配置: $CLAUDE_HOME/settings.json"
fi

# ── 跳过 MCP 配置 ───────────────────────────────────────────
info "跳过 ~/.mcp.json（包含你的路径，不自动覆盖）"

# ── 收尾 ────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
if [ $UPDATED -eq 0 ]; then
    echo -e "${GREEN}  ✅ 所有文件已是最新，无需更新${RESET}"
else
    echo -e "${GREEN}  ✅ 已更新 $UPDATED 个文件${RESET}"
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo "重启 Claude Code 使更新生效: claude"
