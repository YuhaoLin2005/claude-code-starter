#!/usr/bin/env python3
"""
Claude Code 状态行 — 项目名、上下文用量、模型、压缩次数。

压缩次数 = 会话累计输入 token / autoCompactWindow（600K）
用于衡量模型"记忆退化程度"：压缩越多 → 越依赖摘要 → 幻觉风险越高。
0 次=完整记忆，1-2 次=正常，3-4 次=注意，5+ 次=建议新开会话。

配置方式（settings.json）:
  "statusLine": {
    "type": "command",
    "command": "python ~/.claude/scripts/statusline.py",
    "padding": 0
  }
"""

import sys, os, json

# Windows GBK 兼容
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stdin.reconfigure(encoding='utf-8', errors='replace')
    except (AttributeError, OSError):
        pass

# 上下文压缩阈值（与 settings.json 中 autoCompactWindow 一致）
COMPACT_THRESHOLD = 600_000

# 终端颜色
GREEN  = '\033[32m'
YELLOW = '\033[33m'
RED    = '\033[31m'
CYAN   = '\033[36m'
DIM    = '\033[2m'
BOLD   = '\033[1m'
RESET  = '\033[0m'


def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except (json.JSONDecodeError, OSError):
        print(f"{DIM}claude-code{RESET}")
        return

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

    # ── 压缩次数（会话累计输入 / 600K）──
    total_input = ctx.get('total_input_tokens', 0) or 0
    compressions = total_input // COMPACT_THRESHOLD

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
