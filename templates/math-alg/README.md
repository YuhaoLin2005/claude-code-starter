# 算法 & 数学项目模板

适用于：Python 科学计算 / 数据分析 / 机器学习 / 数学建模项目。

## 使用方法

将此模板的 `CLAUDE.md` 片段合并到你项目的 `CLAUDE.md` 中（或直接复制使用）。

## 模板特点

- 数理推导约束（公式正确性、边界条件验证）
- 矩阵/向量运算优化（NumPy 向量化、避免显式循环）
- 数据处理规范（空值处理、类型转换、大规模数据分块）
- 模型训练最佳实践（随机种子固定、验证集隔离、超参数记录）
- 可视化规范（中文字体、图表标注、色盲友好）

## 包含规则

复制以下规则文件到项目 `.claude/rules/`：
- `code-quality.md`（含数值计算专项：浮点比较、溢出检查）
- `performance.md`（含向量化优化、内存管理）
- `testing.md`（含数值测试：容差断言、边界用例）

## CLAUDE.md 模板

```markdown
# 项目概述

这是一个 [数据分析 / 机器学习 / 数学建模] 项目，使用 Python 开发。

## 技术栈
- 语言：Python 3.11+
- 核心库：NumPy, SciPy, Pandas
- 机器学习：[scikit-learn / PyTorch / XGBoost]
- 可视化：Matplotlib, Seaborn
- 实验管理：[MLflow / WandB / 手动记录]

## 数值计算规范
- 浮点数比较使用 np.isclose() 或容差断言，禁止 ==
- 矩阵运算优先使用 NumPy 向量化，避免 Python 显式循环
- 大数组操作注意内存：使用 chunked processing 或 memory mapping
- 数值溢出检查：大整数用 Python int（无限精度），小数用 np.float64 注意范围

## 数据处理
- 读取数据后立即检查：shape, dtypes, null counts, duplicated
- 空值处理策略必须明确记录（drop / fill / interpolate）
- 类别变量编码方式需要注释说明原因
- 数据划分前固定随机种子（np.random.seed / random_state）

## 模型训练
- 训练/验证/测试集划分必须在任何预处理之前
- 所有超参数记录在配置文件中
- 验证指标至少包含：主指标 + 置信区间
- 避免数据泄露：scaler.fit() 只用训练集

## 可视化
- 图表必须包含：标题、轴标签、图例、单位
- 中文使用 SimHei 或 Noto Sans SC 字体
- 配色考虑色盲友好（使用 seaborn colorblind palette）
- 保存格式：SVG（矢量）优先，PNG 备选

## 数学公式/推导
- 关键公式在代码中引用编号（如 "公式(3)"），对应文档/论文
- 数学推导的代码实现需要包含验证用例（代入已知值检查）
- 概率/统计计算注意数值稳定性（log-space、softmax 稳定实现）
```

> 📌 完整规则文件见仓库根目录 `.claude/rules/`。
