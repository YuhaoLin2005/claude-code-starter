"""
Claude Code Status Line — DeepSeek 定价校准版.

Claude Code 默认按 Anthropic 官方定价（$3/M 输入、$15/M 输出）计算 cost.total_cost_usd。
使用 DeepSeek API 后端时，这个数字虚高 10-50 倍。

本脚本绕开 Claude Code 的 cost 字段，直接按 token 数 × DeepSeek 实际定价重算：
- 输入（90% 缓存命中，混合价）：$0.10/M tokens
- 输出（无缓存）：$1.10/M tokens
- USD → RMB：7.2

使用方法：在 settings.json 中配置：
  "statusLine": { "type": "command", "command": "python ~/.claude/scripts/statusline.py" }
"""
import json
import sys


# ── DeepSeek V4 Pro 定价（USD / 百万 tokens）────────────────────
# 缓存命中价 $0.07/M，常规价 $0.28/M
# 90% 缓存命中率 → 混合输入价 = 0.9×0.07 + 0.1×0.28 ≈ 0.091
INPUT_PRICE_PER_M = 0.10   # 混合缓存输入价（略保守）
OUTPUT_PRICE_PER_M = 1.10  # 输出价（无缓存优惠）
USD_TO_RMB = 7.2

# ── 外观 ────────────────────────────────────────────────────────
BAR_WIDTH = 10


def colorize(text, code):
    return f"\033[{code}m{text}\033[0m"


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, KeyboardInterrupt):
        print("", end="")
        return

    # ── 模型名 ──────────────────────────────────────────────────
    model = data.get("model", {}).get("display_name", "DS")
    if "deepseek" in model.lower():
        model = model.replace("deepseek", "DS", 1)
    if len(model) > 16:
        model = model[:15] + "…"

    # ── Token 用量 ─────────────────────────────────────────────
    cw = data.get("context_window", {})
    input_tokens = cw.get("total_input_tokens", 0)
    output_tokens = cw.get("total_output_tokens", 0)
    context_size = cw.get("context_window_size", 200000)

    # 兼容新版字段名
    cu = cw.get("current_usage", {})
    if isinstance(cu, dict):
        input_tokens = cu.get("input_tokens", input_tokens)
        output_tokens = cu.get("output_tokens", output_tokens)

    # ── 成本（DeepSeek 定价）────────────────────────────────────
    input_cost = input_tokens * INPUT_PRICE_PER_M / 1_000_000
    output_cost = output_tokens * OUTPUT_PRICE_PER_M / 1_000_000
    total_rmb = (input_cost + output_cost) * USD_TO_RMB

    # ── 上下文用量 ──────────────────────────────────────────────
    total_tokens = input_tokens + output_tokens
    pct = min(99, int(total_tokens * 100 / max(1, context_size)))

    filled = min(BAR_WIDTH, int(pct * BAR_WIDTH / 100))
    bar = "█" * filled + "░" * (BAR_WIDTH - filled)

    if pct < 40:
        bar_str = colorize(bar, 32)
        pct_str = colorize(f"{pct}%", 32)
    elif pct < 60:
        bar_str = colorize(bar, 33)
        pct_str = colorize(f"{pct}%", 33)
    else:
        bar_str = colorize(bar, 31)
        pct_str = colorize(f"{pct}%", 31)

    # ── 格式化成本 ──────────────────────────────────────────────
    if total_rmb < 0.01:
        cost_str = colorize(f"¥{total_rmb:.4f}", 2)
    elif total_rmb < 1:
        cost_str = f"¥{total_rmb:.3f}"
    else:
        cost_str = f"¥{total_rmb:.2f}"

    # ── 输出 ────────────────────────────────────────────────────
    print(f"{model} {bar_str} {pct_str} | {cost_str}", end="")


if __name__ == "__main__":
    main()
