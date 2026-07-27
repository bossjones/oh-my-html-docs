# Using Copilot CLI in GitHub Actions with GITHUB_TOKEN

Run Copilot CLI in a GitHub Actions workflow using the built-in GITHUB_TOKEN, without a personal access token.

For background on authentication options and how billing works when running Copilot CLI in GitHub Actions, see [About using Copilot CLI in GitHub Actions](/en/copilot/concepts/agents/copilot-cli/copilot-cli-in-github-actions).

## Enabling the policy

For workflows in your organization to use Copilot CLI with `GITHUB_TOKEN`, the policy must be enabled. This policy is enabled by default for organizations with Copilot CLI turned on, but you can confirm or change this setting in your organization's policy settings.

1. Navigate to the policy settings for your organization. See [Managing policies and features for GitHub Copilot in your organization](/en/copilot/how-tos/administer-copilot/manage-for-organization/manage-policies).
2. Under "Copilot CLI", confirm that **Allow use of Copilot CLI billed to the organization** is selected.

## Recommended approach: GitHub Agentic Workflows

For most automation use cases, we recommend using [GitHub Agentic Workflows](https://github.com/github/gh-aw) rather than invoking `copilot` directly in workflow steps. Agentic workflows use `GITHUB_TOKEN` authentication by default and include additional guardrails suited for automated environments.

For setup instructions, see [Quick Start](https://github.github.com/gh-aw/setup/quick-start/) in the GitHub Agentic Workflows documentation. Your workflow must also grant the `copilot-requests: write` permission. See [Permissions](https://github.github.com/gh-aw/reference/permissions/) in the GitHub Agentic Workflows documentation.

## Using Copilot CLI directly in a workflow

If you need to invoke Copilot CLI directly in a workflow step, install the CLI with npm.

> \[!WARNING]
> Invoking Copilot CLI directly in workflow steps gives it broad access to your workflow environment. Review your workflow triggers and permissions carefully before using this approach. Workflows triggered by pull requests from forks are particularly at risk.

### Example workflow

```yaml
name: Copilot CLI example
on: [push]

permissions:
  contents: read
  copilot-requests: write

jobs:
  copilot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Install Copilot CLI
        run: npm install -g @github/copilot
      - name: Run Copilot
        run: copilot --yolo -p "Summarize the changes in this commit"
        env:
          GITHUB_TOKEN: $
```

Key details about this example:

* The `--yolo` flag suppresses interactive prompts, which is required for non-interactive environments like GitHub Actions.
* The `copilot-requests: write` permission is required for the workflow to make Copilot requests.
* The `GITHUB_TOKEN` provided by GitHub Actions handles authentication automatically, no additional secrets are needed.

> \[!NOTE]
> You must be on a recent version of Copilot CLI to use `GITHUB_TOKEN` authentication. Update with `copilot update`, or reinstall the latest version with `npm install -g @github/copilot`.

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli-in-actions (fetched 2026-07-27) -->
