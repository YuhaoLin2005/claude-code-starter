#!/usr/bin/env bash
# ============================================================
# init.sh — DeepSeek Claude Code 脚手架 一键初始化
# ============================================================
# 用法:
#   curl -sL https://raw.githubusercontent.com/YuhaoLin2005/claude-code-starter/main/init.sh | bash
#   或
#   git clone && cd claude-code-starter && ./init.sh
# ============================================================
set -e

# ── 颜色 ────────────────────────────────────────────────────
RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'
BLUE='\033[34m'; BOLD='\033[1m'; RESET='\033[0m'
pass() { echo -e "   ${GREEN}✅ $1${RESET}"; }
fail() { echo -e "   ${RED}❌ $1${RESET}"; }
warn() { echo -e "   ${YELLOW}⚠️  $1${RESET}"; }
info() { echo -e "   ${BLUE}ℹ️  $1${RESET}"; }

echo -e "${BOLD}DeepSeek Claude Code 脚手架 — 一键初始化${RESET}\n"

# ── 确定工作目录 ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 检测是本地 clone 还是 curl pipe
if [ -f "$SCRIPT_DIR/.claude/settings.json" ]; then
    REPO_DIR="$SCRIPT_DIR"
    info "检测到本地仓库: $REPO_DIR"
else
    # curl pipe 模式: 克隆到临时目录
    REPO_DIR="/tmp/claude-code-starter-$$"
    info "克隆仓库到: $REPO_DIR"
    git clone --depth 1 https://github.com/YuhaoLin2005/claude-code-starter.git "$REPO_DIR" 2>/dev/null || {
        fail "克隆失败，请检查网络连接"
        exit 1
    }
fi

# ── 确定目标目录 ────────────────────────────────────────────
CLAUDE_HOME="${HOME}/.claude"
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    Darwin)                 OS="mac" ;;
    Linux)                  OS="linux" ;;
    *)                      OS="unknown" ;;
esac
info "操作系统: $OS"

# ── Step 1: 检测 DeepSeek 配置 ──────────────────────────────
echo -e "\n${BOLD}🔍 Step 1: 检测全局 DeepSeek 配置${RESET}"
SETTINGS_FILE="$CLAUDE_HOME/settings.json"
FIXES_NEEDED=0

if [ -f "$SETTINGS_FILE" ]; then
    pass "找到 $SETTINGS_FILE"

    # 检查 ANTHROPIC_BASE_URL
    if grep -q "api.deepseek.com/anthropic" "$SETTINGS_FILE" 2>/dev/null; then
        pass "ANTHROPIC_BASE_URL → DeepSeek"
    else
        fail "ANTHROPIC_BASE_URL 未指向 DeepSeek"
        warn "请添加: \"ANTHROPIC_BASE_URL\": \"https://api.deepseek.com/anthropic\""
        FIXES_NEEDED=$((FIXES_NEEDED + 1))
    fi

    # 检查 ATTRIBUTION_HEADER
    if grep -q '"CLAUDE_CODE_ATTRIBUTION_HEADER".*"0"' "$SETTINGS_FILE" 2>/dev/null; then
        pass "ATTRIBUTION_HEADER 已关闭 → 缓存命中率 90%+"
    else
        fail "ATTRIBUTION_HEADER 未关闭 → 缓存命中率可能只有 ~50%"
        warn "请添加: \"CLAUDE_CODE_ATTRIBUTION_HEADER\": \"0\""
        FIXES_NEEDED=$((FIXES_NEEDED + 1))
    fi

    # 检查子 Agent 模型
    if grep -q '"CLAUDE_CODE_SUBAGENT_MODEL".*"deepseek-v4-pro"' "$SETTINGS_FILE" 2>/dev/null; then
        pass "子 Agent 模型: deepseek-v4-pro"
    else
        fail "子 Agent 未强制 pro 模型 → 复杂任务输出质量可能下降"
        warn "请添加: \"CLAUDE_CODE_SUBAGENT_MODEL\": \"deepseek-v4-pro\""
        FIXES_NEEDED=$((FIXES_NEEDED + 1))
    fi

    # 检查 ANTHROPIC_AUTH_TOKEN（仅检查是否存在，不检查值）
    if grep -q "ANTHROPIC_AUTH_TOKEN" "$SETTINGS_FILE" 2>/dev/null || [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        pass "API Key 已设置"
    else
        warn "API Key 未检测到。请在 settings.json 中设置 ANTHROPIC_AUTH_TOKEN"
        warn "或在环境变量中设置 ANTHROPIC_AUTH_TOKEN"
    fi
else
    fail "未找到 $SETTINGS_FILE"
    echo ""
    echo -e "   ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "   ${YELLOW}需要先配置 Claude Code 连接 DeepSeek API${RESET}"
    echo -e "   ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo "   方法一：直接创建配置文件"
    echo "   mkdir -p ~/.claude"
    echo '   cat > ~/.claude/settings.json << EOF'
    echo '   {'
    echo '     "env": {'
    echo '       "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",'
    echo '       "ANTHROPIC_AUTH_TOKEN": "sk-你的Key",'
    echo '       "ANTHROPIC_MODEL": "deepseek-v4-pro",'
    echo '       "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-pro",'
    echo '       "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",'
    echo '       "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000"'
    echo '     }'
    echo '   }'
    echo '   EOF'
    echo ""
    echo "   方法二：使用本仓库的 settings.json 模板"
    echo "   cp $REPO_DIR/.claude/settings.json ~/.claude/settings.json"
    echo "   # 然后编辑 ANTHROPIC_AUTH_TOKEN"
    echo ""
    warn "配好全局 settings.json 后重新运行本脚本"
    FIXES_NEEDED=$((FIXES_NEEDED + 99))
fi

if [ $FIXES_NEEDED -gt 0 ] && [ $FIXES_NEEDED -lt 99 ]; then
    echo ""
    warn "发现 $FIXES_NEEDED 项可优化配置"
    read -p "   是否自动修复？ [Y/n] " -r AUTO_FIX
    if [ "$AUTO_FIX" != "n" ] && [ "$AUTO_FIX" != "N" ]; then
        info "请手动编辑 ~/.claude/settings.json 添加上述配置项"
        info "(自动修复需安装 jq，暂不支持直接修改 JSON)"
    fi
fi

# ── Step 2: 选择项目类型 ────────────────────────────────────
echo -e "\n${BOLD}📂 Step 2: 选择项目类型${RESET}"
echo "   1) 前端 — React / Vue / Next.js / TypeScript"
echo "   2) 后端 — Go / Python / Java / Node.js API"
echo "   3) 算法 & 数学 — Python NumPy / PyTorch / SciPy"
echo "   4) 通用 — 不确定，全部规则都要"
echo "   0) 跳过 — 不复制场景模板"

read -p "   请选择 [1-4, 0]: " -r SCENE
case "$SCENE" in
    1) SCENE_DIR="frontend"; SCENE_NAME="前端" ;;
    2) SCENE_DIR="backend";  SCENE_NAME="后端" ;;
    3) SCENE_DIR="math-alg"; SCENE_NAME="算法数学" ;;
    4) SCENE_DIR="";         SCENE_NAME="通用" ;;
    0) SCENE_DIR="skip";     SCENE_NAME="" ;;
    *) SCENE_DIR="";         SCENE_NAME="通用"; info "默认: 通用" ;;
esac

# ── Step 3: 复制配置 ────────────────────────────────────────
echo -e "\n${BOLD}📋 Step 3: 安装配置文件${RESET}"

# 创建目录
mkdir -p "$CLAUDE_HOME/rules"
mkdir -p "$CLAUDE_HOME/agents"
mkdir -p "$CLAUDE_HOME/commands"
mkdir -p "$CLAUDE_HOME/scripts"
mkdir -p "$CLAUDE_HOME/docs"

# 复制规则文件
cp "$REPO_DIR/.claude/rules/"*.md "$CLAUDE_HOME/rules/" 2>/dev/null
pass "规则文件 → ~/.claude/rules/ ($(ls "$REPO_DIR/.claude/rules/"*.md 2>/dev/null | wc -l) 个)"

# 复制 Agent 定义
cp "$REPO_DIR/.claude/agents/"*.md "$CLAUDE_HOME/agents/" 2>/dev/null
pass "Agent 定义 → ~/.claude/agents/ ($(ls "$REPO_DIR/.claude/agents/"*.md 2>/dev/null | wc -l) 个)"

# 复制命令
cp "$REPO_DIR/.claude/commands/"*.md "$CLAUDE_HOME/commands/" 2>/dev/null
pass "斜杠命令 → ~/.claude/commands/ ($(ls "$REPO_DIR/.claude/commands/"*.md 2>/dev/null | wc -l) 个)"

# 复制脚本
cp "$REPO_DIR/.claude/scripts/"*.py "$CLAUDE_HOME/scripts/" 2>/dev/null
pass "Python 脚本 → ~/.claude/scripts/"

# 复制文档
cp "$REPO_DIR/.claude/docs/"*.md "$CLAUDE_HOME/docs/" 2>/dev/null 2>/dev/null || true
[ -f "$REPO_DIR/docs/DeepSeek适配细节.md" ] && cp "$REPO_DIR/docs/DeepSeek适配细节.md" "$CLAUDE_HOME/docs/" 2>/dev/null

# 复制 CLAUDE.md 和 RTK.md
cp "$REPO_DIR/.claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" 2>/dev/null && pass "CLAUDE.md → ~/.claude/"
cp "$REPO_DIR/.claude/RTK.md" "$CLAUDE_HOME/RTK.md" 2>/dev/null && pass "RTK.md → ~/.claude/"
cp "$REPO_DIR/.claude/keybindings.json" "$CLAUDE_HOME/keybindings.json" 2>/dev/null && pass "快捷键 → ~/.claude/"

# 复制 settings.json（仅在不存在时）
if [ ! -f "$SETTINGS_FILE" ]; then
    cp "$REPO_DIR/.claude/settings.json" "$SETTINGS_FILE"
    pass "settings.json → ~/.claude/ (全新安装)"
    warn "请编辑 ANTHROPIC_AUTH_TOKEN 填入你的 DeepSeek API Key"
else
    info "settings.json 已存在，跳过覆盖（如需更新请手动合并）"
fi

# 复制 MCP 配置
if [ ! -f "$HOME/.mcp.json" ]; then
    cp "$REPO_DIR/templates/mcp.json.example" "$HOME/.mcp.json"
    pass "MCP 配置 → ~/.mcp.json"
    warn "请编辑 ~/.mcp.json 中的 filesystem 路径"
else
    info "~/.mcp.json 已存在，跳过覆盖"
fi

# ── Step 4: 场景模板 ────────────────────────────────────────
if [ "$SCENE_DIR" != "skip" ]; then
    echo -e "\n${BOLD}📂 Step 4: 安装场景模板 (${SCENE_NAME})${RESET}"
    TEMPLATE_DIR="$REPO_DIR/templates/${SCENE_DIR}"
    if [ -n "$SCENE_DIR" ] && [ -f "$TEMPLATE_DIR/README.md" ]; then
        info "场景模板: $SCENE_NAME"
        info "模板位置: $TEMPLATE_DIR/README.md"
        info "请根据模板 README 的内容创建项目 CLAUDE.md"
    else
        info "通用模式: 使用 ~/.claude/CLAUDE.md 作为基础"
    fi
fi

# ── Step 5: RTK 提示 ────────────────────────────────────────
echo -e "\n${BOLD}⚡ Step 5: RTK Token 优化${RESET}"
if command -v rtk &>/dev/null; then
    pass "RTK 已安装 ($(rtk --version 2>/dev/null || echo 'ok'))"
else
    warn "RTK 未安装（可选）。安装后 shell 输出节省 ~55% token"
    info "安装: cargo install rtk"
    info "验证: rtk --version"
fi

# ── 收尾 ────────────────────────────────────────────────────
echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  ✅ 初始化完成！${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "\n${BOLD}📋 收尾 Checklist:${RESET}"
echo "   [ ] 编辑 ~/.claude/settings.json → 填入 ANTHROPIC_AUTH_TOKEN"
echo "   [ ] 编辑 ~/.mcp.json → 修改 filesystem 路径为你的用户名"
echo "   [ ] (可选) 安装 RTK: cargo install rtk"
echo "   [ ] 重启终端 → 运行 claude"
echo ""
echo -e "${GREEN}启动后试试:${RESET}"
echo "   /status      # 检查配置状态"
echo "   /desensitize # 脱敏扫描（push 前）"
echo "   rtk gain     # 查看 Token 节省统计"

# 清理临时目录
if [ "$REPO_DIR" != "$SCRIPT_DIR" ] && [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
fi
