# FinCore — Engineering Instructions

## Project

FinCore is an educational digital banking and payment
processing platform. It uses synthetic data and does not
process real money or connect to real banking infrastructure.

Primary stack:
- Java 21 + Spring Boot
- Go
- PostgreSQL
- Docker Compose
- REST/JSON

Read the relevant specification before implementing a feature.

## Engineering Principles

- Prefer simple, maintainable solutions.
- Respect service boundaries and data ownership.
- Follow the existing architecture and conventions.
- Do not introduce dependencies or infrastructure without
  a concrete technical reason.
- Do not expand the task beyond its approved scope.
- Do not invent business rules or architectural decisions.

## Financial Safety — Non-Negotiable

- Never use float or double for monetary amounts.
- Represent money using integer minor units and an explicit currency.
- Every posted journal entry must balance debits and credits.
- Posted ledger records are immutable.
- Corrections must use compensating entries.
- Financial operations must preserve atomicity.
- Idempotency must be enforced persistently.
- Concurrent operations must not allow double spending.
- The ledger is the financial source of truth.
- Balance projections must remain transactionally consistent
  and reconstructible.

Any change affecting these rules requires explicit human review.

## Implementation Workflow

Before coding:
1. Read the applicable specification.
2. Inspect the existing implementation and conventions.
3. Identify affected components and data ownership.
4. Present a concise implementation plan.
5. Identify tests for normal and failure scenarios.

During implementation:
- Keep changes focused.
- Avoid unrelated refactoring.
- Do not modify another service's database directly.
- Do not change API contracts without authorization.
- Do not weaken or remove tests to make a change pass.

After implementation:
1. Run relevant tests.
2. Run formatting, compilation and static checks.
3. Review the diff.
4. Report commands executed and their actual results.
5. Report limitations and unresolved risks.

## AI Agent Restrictions

- Do not commit or push unless explicitly requested.
- Do not modify secrets or environment credentials.
- Do not run destructive database commands without approval.
- Do not modify financial invariants or approved architecture
  autonomously.
- Ask before making decisions not covered by the specification.
- Never claim a test passed unless it was executed successfully.