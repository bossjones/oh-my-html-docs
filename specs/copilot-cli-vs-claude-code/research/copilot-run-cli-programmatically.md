# Running GitHub Copilot CLI programmatically

Use Copilot CLI in the terminal, in scripts, or in Actions workflows.

## Introduction

You can pass a prompt directly to Copilot CLI in a single command, without entering an interactive session. This allows you to use Copilot directly from the terminal, but also allows you to use the CLI programmatically in scripts, CI/CD pipelines, and automation workflows.

To use Copilot CLI programmatically you can do either of the following.

* Use the `copilot` command with the `-p` or `--prompt` command-line option, followed by your prompt:

  ```shell copy
  copilot -p "Explain this file: ./complex.ts"
  ```

* Pipe a prompt to the `copilot` command:

  ```shell copy
  echo "Explain this file: ./complex.ts" | copilot
  ```

  > \[!NOTE]
  > Piped input is ignored if you also provide a prompt with the `-p` or `--prompt` option.

## Tips for using Copilot CLI programmatically

* **Provide precise prompts** — clear, unambiguous instructions produce better results than vague requests. The more context you give—file names, function names, the exact change—the less guesswork Copilot has to do.
* **Quote prompts carefully** — use single quotes around your prompt if you want to avoid shell interpretation of special characters.
* **Always give minimal permissions** — use the `--allow-tool=[TOOLS...]` and `--allow-url=[URLs...]` command-line options to give Copilot permission to use only the tools and access that are necessary to complete the task. Avoid using overly permissive options (such as `--allow-all`) unless you are working in a sandbox environment.
* **Use `-s` (silent)** when capturing output. This suppresses session metadata so you get clean text.
* **Use `--no-ask-user`** to prevent the agent from attempting to ask clarifying questions.
* **Set a model explicitly** with `--model` for consistent behavior across environments.

See [GitHub Copilot CLI programmatic reference](/en/copilot/reference/copilot-cli-reference/cli-programmatic-reference) for options that are particularly useful when running Copilot CLI programmatically.

## CI/CD integration

A common use case for running Copilot CLI programmatically is to include a CLI command in a CI/CD workflow step.

This extract from a GitHub Actions workflow shows a simple example of running a Copilot CLI command.

```yaml
# Workflow step using Copilot CLI
- name: Generate test coverage report
  env:
    COPILOT_GITHUB_TOKEN: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
  run: |
    copilot -p "Run the test suite and produce a coverage summary" \
      -s --allow-tool='shell(npm:*), write' --no-ask-user
```

For more information, see [Automating tasks with Copilot CLI and GitHub Actions](/en/copilot/how-tos/copilot-cli/automate-copilot-cli/automate-with-actions).

## Examples of programmatic usage

### Generate a commit message

```bash copy
copilot -p 'Write a commit message in plain text for the staged changes' -s \
  --allow-tool='shell(git:*)'
```

### Summarize a file

```bash copy
copilot -p 'Summarize what src/auth/login.ts does in no more than 100 words' -s
```

### Write tests for a module

```bash copy
copilot -p 'Write unit tests for src/utils/validators.ts' \
  --allow-tool='write, shell(npm:*), shell(npx:*)'
```

### Fix lint errors

```bash copy
copilot -p 'Fix all ESLint errors in this project' \
  --allow-tool='write, shell(npm:*), shell(npx:*), shell(git:*)'
```

### Explain a diff

```bash copy
copilot -p 'Explain the changes in the latest commit on this branch and flag any potential issues' -s
```

### Code review a branch

Use `/review` slash command to have the built-in `code-review` agent review the code changes on the current branch.

```bash copy
copilot -p '/review the changes on this branch compared to main. Focus on bugs and security issues.' \
  -s --allow-tool='shell(git:*)'
```

### Generate documentation

```bash copy
copilot -p 'Generate JSDoc comments for all exported functions in src/api/' \
  --allow-tool=write
```

### Export a session

Save the full session transcript to a Markdown file on the local filesystem.

```bash copy
copilot -p "Audit this project's dependencies for vulnerabilities" \
  --allow-tool='shell(npm:*), shell(npx:*)' \
  --share='./audit-report.md'
```

Save the session transcript to a gist on GitHub.com for easy sharing.

```bash copy
copilot -p 'Summarize the architecture of this project' --share-gist
```

> \[!NOTE]
> Gists are not available to Enterprise Managed Users, or if you use GitHub Enterprise Cloud with data residency (\*.ghe.com).

## Shell scripting patterns

### Capture Copilot's output in a variable

```bash copy
result=$(copilot -p 'What version of Node.js does this project require? \
  Give the number only. No other text.' -s)
echo "Required Node version: $result"
```

### Use in a conditional

```bash copy
if copilot -p 'Does this project have any TypeScript errors? Reply only YES or NO.' -s \
  | grep -qi "no"; then
  echo "No type errors found."
else
  echo "Type errors detected."
fi
```

### Process multiple files

```bash copy
for file in src/api/*.ts; do
  echo "--- Reviewing $file ---" | tee -a review-results.md
  copilot -p "Review $file for error handling issues" -s --allow-all-tools | tee -a review-results.md
done
```

## Further reading

* [GitHub Copilot CLI](/en/copilot/how-tos/copilot-cli)
* [GitHub Copilot CLI programmatic reference](/en/copilot/reference/copilot-cli-reference/cli-programmatic-reference)
* [GitHub Copilot CLI command reference](/en/copilot/reference/copilot-cli-reference/cli-command-reference#command-line-options)

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/automate-copilot-cli/run-cli-programmatically (fetched 2026-07-27) -->
