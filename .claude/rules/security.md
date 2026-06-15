# Security

## Repository Visibility — PRIVATE vs PUBLIC (CRITICAL)

| 仓库类型 | 用途 | 要求 |
|---------|------|------|
| **Private** | 个人完整备份 | 可含路径/配置，不对外 |
| **Public** | 分享/模板 | 必须脱敏审查后才能 push |

**Public repo push checklist:**
- [ ] 无个人文件路径（`C:\Users\xxx`、`/home/xxx`）
- [ ] 无 token/key/secret/password
- [ ] 无内部 IP、服务器地址
- [ ] settings.local.json 在 .gitignore 中

## Mandatory Checks (Before ANY Commit)

- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Auth verified, rate limiting on endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management

- NEVER hardcode secrets in source code
- ALWAYS use environment variables or a secret manager
- Validate required secrets at startup
- Rotate any secrets that may have been exposed

## Security Review Triggers

STOP and use security-reviewer agent when modifying:
- Authentication / authorization code
- User input handling / database queries
- File system operations / external API calls
- Cryptographic operations / payment code

## Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues

## Common Vulnerabilities to Catch

- Hardcoded credentials, SQL injection, XSS
- Path traversal, CSRF, authentication bypasses
- N+1 queries, missing pagination, unbounded queries
