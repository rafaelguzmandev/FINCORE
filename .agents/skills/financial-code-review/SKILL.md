# Financial Code Review

## Purpose

Review changes that may affect financial correctness.

## Review Checklist

- Are monetary values represented safely?
- Are debit and credit postings balanced?
- Are posted records immutable?
- Is the operation atomic?
- Is idempotency persisted and enforced?
- Can concurrent requests cause double spending?
- Are database constraints sufficient?
- Are failure and retry scenarios handled?
- Can the balance projection be reconciled with the ledger?
- Is sensitive information excluded from logs?

## Output

Classify findings by severity:
- Critical
- High
- Medium
- Low

For each finding include:
- File and location.
- Problem.
- Potential impact.
- Suggested correction.

Do not modify code unless explicitly requested.