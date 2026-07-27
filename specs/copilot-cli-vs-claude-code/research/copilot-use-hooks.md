# Using hooks with GitHub Copilot CLI

Extend GitHub Copilot agent behavior with custom shell commands at key points during agent execution.

Hooks allow you to extend and customize the behavior of GitHub Copilot agents by executing custom shell commands at key points during agent execution. For a conceptual overview of hooks—including details of the available hook triggers—see [About hooks for GitHub Copilot](/en/copilot/concepts/agents/hooks).

## Prerequisite

**Windows users only:** The example hooks in this article are designed to run on Windows, Linux, and macOS. For Windows, they use PowerShell and require you to have PowerShell 7.0 or later installed and in your PATH. You can check your PowerShell version by running `pwsh --version` in a terminal. To install PowerShell, run `winget install Microsoft.PowerShell` then restart your terminal.

## Creating a repository-level hook

1. Create a new `NAME.json` file (where `NAME` describes the purpose of the file) in the `.github/hooks/` folder of your repository.

2. In your text editor, copy and paste the following hook template. Remove any hooks you don't plan on using from the `hooks` array.

   ```json copy
   {
     "version": 1,
     "hooks": {
       "sessionStart": [...],
       "sessionEnd": [...],
       "userPromptSubmitted": [...],
       "preToolUse": [...],
       "postToolUse": [...],
       "errorOccurred": [...]
     }
   }
   ```

3. Configure your hook syntax under the `bash` and `powershell` keys, or directly reference script files you have created.

   > \[!NOTE]
   > Include both a `bash` key (with a script for Linux and macOS) and a `powershell` key (for a script for Windows) to allow the hooks to run on all three operating systems. Copilot uses the appropriate key based on the user's operating system.

   * This example runs a script that outputs the start date of the session to a log file using the `sessionStart` hook:

     ```json copy
     "sessionStart": [
       {
         "type": "command",
         "bash": "echo \"Session started: $(date)\" >> logs/session.log",
         "powershell": "Add-Content -Path logs/session.log -Value \"Session started: $(Get-Date)\"",
         "cwd": ".",
         "timeoutSec": 10
       }
     ],
     ```

   * This example calls out to an external `log-prompt` script:

     ```json copy
     "userPromptSubmitted": [
       {
         "type": "command",
         "bash": "./scripts/log-prompt.sh",
         "powershell": "./scripts/log-prompt.ps1",
         "cwd": "scripts",
         "env": {
           "LOG_LEVEL": "INFO"
         }
       }
     ],
     ```

     For a full reference on the input JSON from agent sessions along with sample scripts, see [GitHub Copilot hooks reference](/en/copilot/reference/hooks-reference).

4. Commit the file to the repository and merge it into the default branch. Your hooks will now run during agent sessions.

## Creating a user-level hook

User-level hooks are configured just like repository-level hooks, but the hook files are stored locally, below your home directory.

The following examples for macOS and Windows show how to configure hooks that will play a sound and display a message box when the CLI finishes responding to a prompt, and when you quit Copilot CLI. Hooks for Linux would be similar to the macOS example, but would use Linux tools for playing sounds and displaying messages.

### User-level example for macOS

1. Create a file called `notification-hooks.json` in `~/.copilot/hooks/`.

   > \[!NOTE]
   > If `COPILOT_HOME` is set, create the file in `$COPILOT_HOME/hooks/`.

2. Copy and paste the following JSON into the file:

   ```json copy
   {
     "version": 1,
     "hooks": {
       "agentStop": [
         {
           "type": "command",
           "bash": "osascript -e 'do shell script \"afplay /System/Library/Sounds/Funk.aiff &> /dev/null &\"' -e 'display dialog \"Agent stopped.\" with title \"Hook-generated message\" buttons {\"OK\"} default button \"OK\"'",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "bash": "osascript -e 'do shell script \"afplay /System/Library/Sounds/Funk.aiff &> /dev/null &\"' -e 'display dialog \"Session ended.\" with title \"Hook-generated message\" buttons {\"OK\"} default button \"OK\"'",
           "timeoutSec": 5
         }
       ]
     }
   }
   ```

3. Start, or restart, Copilot CLI.

   > \[!NOTE]
   > Changes to hook configurations are loaded when the CLI starts.

4. Enter a prompt and check that you hear a sound and see a message box when the agent finishes responding, and when you quit the CLI.

5. Delete the `notification-hooks.json` file to remove these hooks.

### User-level example for Windows

1. Create a file called `notification-hooks.json` in `%USERPROFILE%\.copilot\hooks\`.

   > \[!NOTE]
   > If `COPILOT_HOME` is set, create the file in `%COPILOT_HOME%\hooks\`.

2. Copy and paste the following JSON into the file:

   ```json copy
   {
     "version": 1,
     "hooks": {
       "agentStop": [
         {
           "type": "command",
           "powershell": "Add-Type -AssemblyName System.Windows.Forms; [System.Media.SystemSounds]::Asterisk.Play(); [System.Windows.Forms.MessageBox]::Show('Agent stopped.', 'Hook-generated message') | Out-Null",
           "timeoutSec": 5
         }
       ],
       "sessionEnd": [
         {
           "type": "command",
           "powershell": "Add-Type -AssemblyName System.Windows.Forms; [System.Media.SystemSounds]::Asterisk.Play(); [System.Windows.Forms.MessageBox]::Show('Session ended.', 'Hook-generated message') | Out-Null",
           "timeoutSec": 5
         }
       ]
     }
   }
   ```

3. Start, or restart, Copilot CLI.

   > \[!NOTE]
   > Changes to hook configurations are loaded when the CLI starts.

4. Enter a prompt and check that you hear a sound and see a message box when the agent finishes responding, and when you quit the CLI.

5. Delete the `notification-hooks.json` file to remove these hooks.

## Troubleshooting

If you run into problems using hooks, use the following table to troubleshoot.

| Issue                   | Action                                                                                                                                                                                                                                                                                                                                                                                                |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hooks are not executing | <ul><li>Verify the JSON file is in the `.github/hooks/` directory.</li><li>Check for valid JSON syntax (for example, `jq .  hooks.json`).</li><li>Ensure `version: 1` is specified in your `hooks.json` file.</li><li>Verify the script you are calling from your hook is executable (`chmod +x script.sh`)</li><li>Check that the script has a proper shebang (for example, `#!/bin/bash`)</li></ul> |
| Hooks are timing out    | <ul><li>The default timeout is 30 seconds. Increase `timeoutSec` in the configuration if needed.</li><li>Optimize script performance by avoiding unnecessary operations.</li></ul>                                                                                                                                                                                                                    |
| Invalid JSON output     | <ul><li>Ensure the output is on a single line.</li><li>On Unix, use `jq -c` to compact and validate the JSON output.</li><li>On Windows, use the `ConvertTo-Json -Compress` command in PowerShell to do the same.</li></ul>                                                                                                                                                                           |

## Debugging

You can debug hooks using the following methods:

* **Enable verbose logging** in the script to inspect the input data and trace script execution.

  ```shell copy
  #!/bin/bash
  set -x  # Enable bash debug mode
  INPUT=$(cat)
  echo "DEBUG: Received input" >&2
  echo "$INPUT" >&2
  # ... rest of script
  ```

* **Test hooks locally** by piping test input into your hook to validate its behavior:

  ```shell copy
  # Create test input
  echo '{"timestamp":1704614400000,"cwd":"/tmp","toolName":"bash","toolArgs":"{\"command\":\"ls\"}"}' | ./my-hook.sh

  # Check exit code
  echo $?

  # Validate output is valid JSON
  ./my-hook.sh | jq .
  ```

## Further reading

* [GitHub Copilot hooks reference](/en/copilot/reference/hooks-reference)
* [About GitHub Copilot cloud agent](/en/copilot/concepts/agents/cloud-agent/about-cloud-agent)
* [About GitHub Copilot CLI](/en/copilot/concepts/agents/copilot-cli/about-copilot-cli)
* [Configure the development environment](/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment)

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks (fetched 2026-07-27) -->
