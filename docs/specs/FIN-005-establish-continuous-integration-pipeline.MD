Description

Establish an initial CI pipeline using GitHub Actions to automatically validate changes submitted to the repository.

The pipeline must ensure that the Go and Java services compile and that their automated tests execute successfully.

Scope

Configure GitHub Actions workflows.

Trigger validation on pull requests and pushes to the main branch.

Configure Go build and test commands.

Configure Java build and test commands.

Validate formatting using the standard tooling for each language.

Ensure failed checks block successful CI completion.

Document the local commands equivalent to CI validation.

Acceptance Criteria

Workflow executes on pull requests.

Go service builds successfully in CI.

Java services build successfully in CI.

Automated tests execute for all services.

Formatting checks are executed.

Failed builds or tests cause the workflow to fail.

CI results are visible in GitHub.

Out of Scope

Deployment pipelines.

Container image publishing.

Production infrastructure.

Advanced security scanning.

Release automation.

Definition of Done

Every pull request receives automated validation for the Go and Java services before it can be considered ready for review.