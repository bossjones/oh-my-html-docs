# Adding custom instructions for GitHub Copilot CLI

Give Copilot additional context on how to understand your project and how to build, test and validate its changes.

GitHub Copilot can provide responses that are tailored to your personal preferences, the way your team works, the tools you use, or the specifics of your project, if you provide it with enough context to do so. Instead of repeatedly adding this contextual detail to your prompts, you can create custom instructions that automatically add this information for you. The additional information is not displayed, but is available to Copilot to allow it to generate higher quality responses.

## Types of custom instructions

GitHub Copilot CLI supports instructions from the following locations.

Unless noted in the table below, Copilot CLI discovers repository and agent instruction files in the **standard locations**: the repository root, the current working directory, intermediate directories between them, and any directories nested in the path of a file it is working on. Modular instruction files (those matching `*.instructions.md`) are path-specific—a file with an `applyTo` value applies only to matching files.

| Location                                                 | Scope and behavior                                                                                                                                              |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `$HOME/.copilot/copilot-instructions.md`                 | User-level instructions that apply across repositories.                                                                                                         |
| `$HOME/.copilot/instructions/**/*.instructions.md`       | Modular user-level instructions.                                                                                                                                |
| `.github/copilot-instructions.md`                        | Repository-wide instructions, discovered in the standard locations.                                                                                             |
| `.github/instructions/**/*.instructions.md`              | Modular repository instructions, discovered in the standard locations but not intermediate directories.                                                         |
| `AGENTS.md`                                              | Agent instructions, discovered in the standard locations. For more information, see the [agentsmd/agents.md repository](https://github.com/agentsmd/agents.md). |
| `CLAUDE.md`                                              | Agent instructions, discovered in the standard locations. Copilot CLI also uses `.claude/CLAUDE.md`.                                                            |
| `GEMINI.md`                                              | Agent instructions, discovered in the standard locations.                                                                                                       |
| Directories listed in `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Additional `AGENTS.md` and `*.instructions.md` files. Separate multiple directories with commas.                                                                |

If you set the `COPILOT_HOME` environment variable, Copilot CLI uses that directory instead of `$HOME/.copilot` for both user-level instruction locations.

Use the `/instructions` command to view the instruction files discovered for the current session and enable or disable individual files.

## How multiple instruction files interact

When multiple applicable user-level and repository instruction files exist, Copilot CLI combines their instructions. It removes duplicate copies of identical user-level `copilot-instructions.md`, repository-wide, and agent instructions, but does not define a general precedence order between these files. Avoid conflicting instructions.

Path-specific instructions are included only when their `applyTo` value matches a file that Copilot CLI is working with. An instruction file that you disable using `/instructions` is not included.

## Creating repository-wide custom instructions

1. In the root of your repository, create a file named `.github/copilot-instructions.md`.

   Create the `.github` directory if it does not already exist.

2. Add natural language instructions to the file, in Markdown format.

   Whitespace between instructions is ignored, so the instructions can be written as a single paragraph, each on a new line, or separated by blank lines for legibility.

   For help on writing effective custom instructions, see [About customizing GitHub Copilot responses](/en/copilot/concepts/prompting/response-customization#writing-effective-custom-instructions).

### Referencing other files

In `.github/copilot-instructions.md`, `AGENTS.md`, or `CLAUDE.md`, use `@` followed by a relative path to include another file. Copilot CLI reads the referenced file immediately and supports references within referenced files.

Referenced files must remain within the repository, or within the custom instructions directory for local instructions. Absolute paths and paths beginning with `~/` are not loaded. File references are not expanded in `GEMINI.md` or `*.instructions.md` files.

## Creating path-specific custom instructions

1. Create the `.github/instructions` directory if it does not already exist.

2. Optionally, create subdirectories of `.github/instructions` to organize your instruction files.

3. Create one or more `NAME.instructions.md` files, where `NAME` indicates the purpose of the instructions. The file name must end with `.instructions.md`.

4. At the start of the file, create a frontmatter block containing the `applyTo` keyword. Use glob syntax to specify what files or directories the instructions apply to.

   For example:

   ```markdown
   ---
   applyTo: "app/models/**/*.rb"
   ---
   ```

   You can specify multiple patterns by separating them with commas. For example, to apply the instructions to all TypeScript files in the repository, you could use the following frontmatter block:

   ```markdown
   ---
   applyTo: "**/*.ts,**/*.tsx"
   ---
   ```

   Glob examples:

   * `*` - will all match all files in the current directory.
   * `**` or `**/*` - will all match all files in all directories.
   * `*.py` - will match all `.py` files in the current directory.
   * `**/*.py` - will recursively match all `.py` files in all directories.
   * `src/*.py` - will match all `.py` files in the `src` directory. For example, `src/foo.py` and `src/bar.py` but *not* `src/foo/bar.py`.
   * `src/**/*.py` - will recursively match all `.py` files in the `src` directory. For example, `src/foo.py`, `src/foo/bar.py`, and `src/foo/bar/baz.py`.
   * `**/subdir/**/*.py` - will recursively match all `.py` files in any `subdir` directory at any depth. For example, `subdir/foo.py`, `subdir/nested/bar.py`, `parent/subdir/baz.py`, and `deep/parent/subdir/nested/qux.py`, but *not* `foo.py` at a path that does not contain a `subdir` directory.

5. Optionally, to prevent the file from being used by either Copilot cloud agent or Copilot code review, add the `excludeAgent` keyword to the frontmatter block. Use either `"code-review"` or `"cloud-agent"`.

   For example, the following file will only be read by Copilot cloud agent.

   ```markdown
   ---
   applyTo: "**"
   excludeAgent: "code-review"
   ---
   ```

   If the `excludeAgent` keyword is not included in the front matterblock, both Copilot code review and Copilot cloud agent will use your instructions.

6. Add your custom instructions in natural language, using Markdown format. Whitespace between instructions is ignored, so the instructions can be written as a single paragraph, each on a new line, or separated by blank lines for legibility.

## Custom instructions in use

Changes you make to custom instructions files are not immediately available for use in active CLI sessions. To apply your changes, exit the current session and then either resume it (for example, run `copilot --continue`), or start a new session (for example, use `/new` from within an interactive session).

## Further reading

* [Support for different types of custom instructions](/en/copilot/reference/custom-instructions-support)
* [Custom instructions](/en/copilot/tutorials/customization-library/custom-instructions)—a curated collection of examples
* [Using custom instructions to unlock the power of Copilot code review](/en/copilot/tutorials/customize-code-review)

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions (fetched 2026-07-27) -->
