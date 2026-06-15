#!/usr/bin/env python3
"""
Claude Code 状态行 — 项目名、上下文用量、模型、压缩次数。

压缩次数通过持久化状态文件追踪：每次检测到上下文用量骤降（被压缩），
计数器 +1。0 次=完整记忆，1-2 次=正常，3-4 次=注意，5+ 次=建议新开会话。

配置方式（settings.json）:
  "statusLine": {
    "type": "command",
    "command": "python ~/.claude/scripts/statusline.py",
    "padding": 0
  }
"""

import sys, os, json, time

# Windows GBK 兼容
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stdin.reconfigure(encoding='utf-8', errors='replace')
    except (AttributeError, OSError):
        pass

# 上下文压缩阈值（与 settings.json 中 autoCompactWindow 一致）
COMPACT_THRESHOLD = 600_000
STATE_FILE = os.path.expanduser('~/.claude/.compaction_state.json')
# 调试：设为 True 时会把 Claude Code 发来的 JSON 写到 ~/.claude/.statusline_debug.json
DEBUG_DUMP = True  # 只写一次，写入后自动关闭

# 终端颜色
GREEN  = '\033[32m'
YELLOW = '\033[33m'
RED    = '\033[31m'
CYAN   = '\033[36m'
DIM    = '\033[2m'
BOLD   = '\033[1m'
RESET  = '\033[0m'


def load_state():
    """从持久化文件读取压缩计数器状态"""
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
    except (json.JSONDecodeError, OSError):
        pass
    return {
        'compactions': 0,
        'peak_used': 0,       # 本次会话中观察到的最大上下文用量
        'last_seen': 0,        # 上一次采样时的 used 值
        'session_start': time.time()
    }


def save_state(state):
    """持久化压缩计数器状态"""
    try:
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            json.dump(state, f, ensure_ascii=False)
    except OSError:
        pass


def detect_compaction(current_used, state):
    """
    检测是否发生了上下文压缩。
    压缩信号：当前用量骤降至峰值的 50% 以下，且峰值接近压缩阈值。
    返回 (new_compaction_count, updated_state)
    """
    peak = state.get('peak_used', 0)
    count = state.get('compactions', 0)

    # 压缩检测条件：
    # 1. 曾经达到过较高水位（> 压缩阈值的 60%）
    # 2. 当前用量骤降到峰值的 50% 以下
    was_near_full = peak > COMPACT_THRESHOLD * 0.6
    just_dropped = current_used < peak * 0.5 and current_used > 0

    if was_near_full and just_dropped:
        count += 1
        peak = current_used  # 重置峰值
        state['compactions'] = count

    # 更新峰值
    if current_used > peak:
        peak = current_used

    state['peak_used'] = peak
    state['last_seen'] = current_used
    return count


def get_tokens_used(ctx):
    """
    尝试从 context_window 数据中提取当前已用 token 数。
    Claude Code 发送的 JSON 字段名可能是 used / total_input_tokens / input_tokens 等。
    尝试多个可能的字段名。
    """
    # 直接字段
    for key in ('used', 'input_tokens', 'total_input_tokens', 'token_count'):
        val = ctx.get(key, 0)
        if val:
            return val

    # 有时在嵌套字段中
    for key in ('current_tokens', 'tokens_used', 'prompt_tokens'):
        val = ctx.get(key, 0)
        if val:
            return val

    # 从 used_percentage 推算: used = total * used_percentage / 100
    pct = ctx.get('used_percentage', 0)
    total = ctx.get('total', 0)
    if pct and total:
        return int(total * pct / 100)

    return 0


def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except (json.JSONDecodeError, OSError):
        print(f"{DIM}claude-code{RESET}")
        return

    # ── 调试转储（只写一次，帮助确认 Claude Code 发来的 JSON 结构）──
    if DEBUG_DUMP:
        debug_file = os.path.expanduser('~/.claude/.statusline_debug.json')
        if not os.path.exists(debug_file):
            try:
                with open(debug_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
            except OSError:
                pass

    # ── 项目名 ──
    cwd = data.get('cwd', '') or data.get('workspace', {}).get('current_dir', '')
    project = os.path.basename(cwd.rstrip('/\\')) if cwd else '?'
    if len(project) > 20:
        project = project[:17] + '...'

    # ── 上下文用量 ──
    ctx = data.get('context_window', {})
    pct = ctx.get('used_percentage', 0) or 0

    if pct >= 60:
        ctx_color, icon = RED,    '●'
    elif pct >= 40:
        ctx_color, icon = YELLOW, '●'
    else:
        ctx_color, icon = GREEN,  '●'

    bar_filled = int(pct / 10)
    bar_empty = 10 - bar_filled
    bar = f'{ctx_color}{"▇" * bar_filled}{DIM}{"▇" * bar_empty}{RESET}'

    # ── 模型 ──
    model_name = data.get('model', {}).get('display_name', '?')

    # ── 压缩次数（持久化计数 + 实时检测）──
    state = load_state()
    current_used = get_tokens_used(ctx)
    compressions = detect_compaction(current_used, state)
    save_state(state)

    # 兜底：如果持久计数器还不到但我们从 total_input_tokens 直接算出更高值
    # （兼容某些 Claude Code 版本会提供准确的累计 total_input_tokens）
    total_input = ctx.get('total_input_tokens', 0) or 0
    direct_compressions = total_input // COMPACT_THRESHOLD
    if direct_compressions > compressions:
        compressions = direct_compressions
        state['compactions'] = compressions
        save_state(state)

    if compressions == 0:
        comp_label = f'{GREEN}记忆完整{RESET}'
    elif compressions <= 2:
        comp_label = f'{GREEN}压缩×{compressions}{RESET}'
    elif compressions <= 4:
        comp_label = f'{YELLOW}压缩×{compressions} ⚠{RESET}'
    else:
        comp_label = f'{RED}压缩×{compressions} 🔥 建议新会话{RESET}'

    # ── 输出 ──
    # 格式: 项目名 ▇▇▇▇░░░░░░ ● 35% | 模型 | 压缩状态
    print(
        f' {BOLD}{project}{RESET} '
        f'{bar} '
        f'{ctx_color}{icon} {int(pct)}%{RESET}'
        f' {DIM}|{RESET} {CYAN}{model_name}{RESET}'
        f' {DIM}|{RESET} {comp_label}'
    )


if __name__ == '__main__':
    main()
