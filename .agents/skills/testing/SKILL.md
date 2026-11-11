# Testing

## Purpose

Design and execute tests for FinCore features.

## Procedure

1. Read the feature specification.
2. Identify business rules and invariants.
3. Identify normal, boundary and failure scenarios.
4. Select the appropriate test level.
5. Implement tests without changing expected behavior
   merely to match the current implementation.
6. Execute the tests.
7. Report actual results.

## FinCore Priorities

- Financial correctness.
- Transaction atomicity.
- Idempotency.
- Concurrency safety.
- Failure recovery.

Never report unexecuted tests as passing.