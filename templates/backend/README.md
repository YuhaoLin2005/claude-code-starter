# 后端工程模板

适用于：Go / Python / Java / Node.js 后端项目。

## 使用方法

将此模板的 `CLAUDE.md` 片段合并到你项目的 `CLAUDE.md` 中（或直接复制使用）。

## 模板特点

- API 设计规范（RESTful）
- 数据库操作约束（参数化查询、迁移管理）
- 错误处理标准（统一错误码、日志规范）
- 安全优先（OWASP Top 10 覆盖）
- 性能约束（N+1 检测、分页、连接池）

## 包含规则

复制以下规则文件到项目 `.claude/rules/`：
- `code-quality.md`（含后端专项：不可变性、错误处理）
- `security.md`（含 SQL 注入、认证、CSRF）
- `testing.md`（含 API 集成测试）
- `performance.md`（含数据库查询优化）
- `patterns.md`（Repository 模式、API 响应格式）

## CLAUDE.md 模板

```markdown
# 项目概述

这是一个 [Go/Python/Java/Node.js] 后端服务，提供 RESTful API。

## 技术栈
- 语言：[Go 1.22+ / Python 3.11+ / Java 17+ / Node.js 20+]
- 框架：[Gin / FastAPI / Spring Boot / Express]
- 数据库：[PostgreSQL / MySQL / MongoDB]
- 缓存：[Redis]
- 消息队列：[RabbitMQ / Kafka]（如有）
- 测试：[go test / pytest / JUnit / Vitest]

## API 规范
- 所有接口返回统一格式：`{ success, data, error, metadata }`
- GET 请求禁止修改数据
- 列表接口必须支持分页（page, limit, total）
- 错误码使用项目统一枚举

## 数据库
- 所有查询使用参数化，禁止字符串拼接 SQL
- 迁移文件放在 `migrations/` 目录
- 查询前检查 N+1：关联数据使用 JOIN 或 batch load
- 大批量写入使用事务

## 安全
- 所有外部输入在边界层校验
- 认证中间件覆盖所有非公开接口
- 敏感配置从环境变量读取，禁止硬编码
- 日志中禁止输出密码、token、密钥

## 错误处理
- 每个外部调用（DB、API、MQ）必须有错误处理
- 错误向上传播时包装上下文信息
- 禁止裸 panic / 未捕获的 exception
```

> 📌 完整规则文件见仓库根目录 `.claude/rules/`。
