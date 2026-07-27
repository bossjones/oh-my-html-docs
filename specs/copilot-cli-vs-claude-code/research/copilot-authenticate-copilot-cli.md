# Authenticating GitHub Copilot CLI

Authenticate Copilot CLI so that you can use Copilot directly from the command line.

## About authentication

If you use your own LLM provider API keys (BYOK), GitHub authentication is not required.

Authentication is required for any other GitHub Copilot CLI usage.

When authentication is required, Copilot CLI supports three methods. The method you use depends on whether you are working interactively or in an automated environment.

* **OAuth device flow**: The default and recommended method for interactive use. When you run `/login` in Copilot CLI, the CLI generates a one-time code and directs you to authenticate in your browser. This is the simplest way to authenticate. See [Authenticating with OAuth](#authenticating-with-oauth).
* **Environment variables**: Recommended for CI/CD pipelines, containers, and non-interactive environments. You set a supported token as an environment variable (`COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN`), and the CLI uses it automatically without prompting. See [Authenticating with environment variables](#authenticating-with-environment-variables).
* **GitHub CLI fallback**: If you have GitHub CLI (`gh`) (note: the `gh` CLI, not `copilot`) installed and authenticated, Copilot CLI can use its token automatically. This is the lowest priority method and activates only when no other credentials are found. See [Authenticating with GitHub CLI](#authenticating-with-github-cli).

Once authenticated, Copilot CLI remembers your login and automatically uses the token for all Copilot API requests. You can log in with multiple accounts, and the CLI will remember the last-used account. Token lifetime and expiration depend on how the token was created on your account or organization settings.

## Unauthenticated use

If you configure Copilot CLI to use your own LLM provider API keys (BYOK), GitHub authentication is **not required**. Copilot CLI can connect directly to your configured provider without a GitHub account or token.

However, without GitHub authentication, the following features are **not available**:

* `/delegate`: Requires Copilot cloud agent, which runs on GitHub's servers
* GitHub MCP server: Requires authentication to access GitHub APIs
* GitHub Code Search: Requires authentication to query GitHub's search index

You can combine BYOK with GitHub authentication to get the best of both: your preferred model for AI responses, plus access to GitHub-hosted features like `/delegate` and code search.

### Offline mode

If you set the `COPILOT_OFFLINE` environment variable to `true`, Copilot CLI runs without contacting GitHub's servers. In offline mode:

* No GitHub authentication is attempted.
* The CLI only makes network requests to your configured BYOK provider.
* Telemetry is fully disabled.

Offline mode is **only fully air-gapped** if your BYOK provider is local or otherwise within the same isolated environment (for example, a model running on-premises with no external network access). If `COPILOT_PROVIDER_BASE_URL` points to a remote or internet-accessible endpoint, prompts and code context will still be sent over the network to that provider. Without offline mode, even when using BYOK without GitHub authentication, telemetry is still sent normally.

### Supported token types

| Token type                | Prefix        | Supported | Notes                                                                                                         |
| ------------------------- | ------------- | --------- | ------------------------------------------------------------------------------------------------------------- |
| OAuth token (device flow) | `gho_`        | Yes       | Default method via `copilot login`                                                                            |
| Fine-grained PAT          | `github_pat_` | Yes       | Must be owned by your personal account (not an organization) with the **Copilot Requests** account permission |
| GitHub App user-to-server | `ghu_`        | Yes       | Via environment variable                                                                                      |
| Classic PAT               | `ghp_`        | No        | Not supported by Copilot CLI                                                                                  |

### How Copilot CLI stores credentials

By default, the CLI stores your OAuth token in your operating system's keychain under the service name `copilot-cli`:

| Platform | Keychain                           |
| -------- | ---------------------------------- |
| macOS    | Keychain Access                    |
| Windows  | Credential Manager                 |
| Linux    | libsecret (GNOME Keyring, KWallet) |

If the system keychain is unavailable—for example, on a headless Linux server without `libsecret` installed—the CLI prompts you to store the token in a plaintext configuration file at `~/.copilot/config.json`.

When you run a command, Copilot CLI checks for credentials in the following order:

1. `COPILOT_GITHUB_TOKEN` environment variable
2. `GH_TOKEN` environment variable
3. `GITHUB_TOKEN` environment variable
4. OAuth token from the system keychain
5. GitHub CLI (`gh auth token`) fallback

> \[!NOTE]
>
> * An environment variable silently overrides a stored OAuth token. If you set `GH_TOKEN` for another tool, the CLI uses that token instead of the OAuth token from `copilot login`. To avoid unexpected behavior, unset environment variables you do not intend the CLI to use.
> * When you configure BYOK provider environment variables (for example, `COPILOT_PROVIDER_BASE_URL`, `COPILOT_PROVIDER_API_KEY`), Copilot CLI uses these for AI model requests regardless of your GitHub authentication status. GitHub tokens are only needed for GitHub-hosted features.

## Authenticating with OAuth

The OAuth device flow is the default authentication method for interactive use. You can authenticate by running `/login` from Copilot CLI or `copilot login` from your terminal.

### Authenticate with `/login`

1. From Copilot CLI, run `/login`.

   ```bash copy
   /login
   ```

2. Select the account you want to authenticate with. For GitHub Enterprise Cloud with data residency, enter the hostname of your instance

   ```text
   What account do you want to log into?
    1. GitHub.com
    2. GitHub Enterprise Cloud with data residency (*.ghe.com)
   ```

3. The CLI displays a one-time user code and automatically copies it to your clipboard and opens your browser.

   ```text
   Waiting for authorization...
   Enter one-time code: 1234-5678 at https://github.com/login/device
   Press any key to copy to clipboard and open browser...
   ```

4. Navigate to the verification URL at `https://github.com/login/device` if your browser did not open automatically.

5. Paste the one-time code in the field on the page.

6. If your organization uses SAML SSO, click **Authorize** next to each organization you want to grant access to.

7. Review the requested permissions and click **Authorize GitHub Copilot CLI**.

8. Return to your terminal. The CLI displays a success message when authentication is complete.

   ```text
   Signed in successfully as Octocat. You can now use Copilot.
   ```

### Authenticate with `copilot login`

1. From the terminal, run `copilot login`. If you are using GitHub Enterprise Cloud with data residency, pass the hostname of your instance.

   ```bash copy
   copilot login
   ```

   For GitHub Enterprise Cloud:

   ```bash copy
   copilot login --host HOSTNAME
   ```

   The CLI displays a one-time user code and automatically copies it to your clipboard and opens your browser.

   ```text
   To authenticate, visit https://github.com/login/device and enter code 1234-5678.
   ```

2. Navigate to the verification URL at `https://github.com/login/device` if your browser did not open automatically.

3. Paste the one-time code in the field on the page.

4. If your organization uses SAML SSO, click **Authorize** next to each organization you want to grant access to.

5. Review the requested permissions and click **Authorize GitHub Copilot CLI**.

6. Return to your terminal. The CLI displays a success message when authentication is complete.

   ```text
   Signed in successfully as Octocat.
   ```

## Authenticating with environment variables

For non-interactive environments, you can authenticate by setting an environment variable with a supported token. This is ideal for CI/CD pipelines, containers, or headless servers.

1. Visit [Fine-grained personal access tokens](https://github.com/settings/personal-access-tokens/new).
2. Under **Resource owner**, select your **personal account**. Do not select an organization. The **Copilot Requests** permission is only available on user-owned fine-grained personal access tokens.
3. Under **Repository access**, select the level of access appropriate for your use case:
   * **Public repositories** if you only need to work with public repos.
   * **All repositories** if you need access across all your current and future repos.
   * **Only select repositories** if you want to restrict access to specific repos.
4. Under **Permissions**, select the **Account** tab.
5. Click **Add permissions** and select **Copilot Requests**.
6. Click **Generate token**.
7. Export the token in your terminal or environment configuration. Use the `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, or `GITHUB_TOKEN` environment variable (in order of precedence).

## Authenticating with GitHub CLI

If you have GitHub CLI installed and authenticated, Copilot CLI can use its token as a fallback. This method has the lowest priority and activates only when no environment variables are set and no stored token is found.

1. Verify that GitHub CLI is authenticated.

   ```bash copy
   gh auth status
   ```

   If you use GitHub Enterprise Cloud with data residency, verify the correct hostname is authenticated.

   ```bash copy
   gh auth status --hostname HOSTNAME
   ```

2. Run `copilot`. The Copilot CLI uses the GitHub CLI token automatically.

3. Run `/user` to verify your authenticated account in the CLI.

## Switching between accounts

Copilot CLI supports multiple accounts. You can list available accounts and switch between them from within the CLI.
To list available accounts, run `/user list` from the Copilot CLI prompt.
To switch to a different account, type `/user switch` on the prompt.

To add another account, run `copilot login` from a new terminal session, or run the login command from within the CLI and authorize with the other account.

## Signing out and removing credentials

To sign out, type `/logout` at the Copilot CLI prompt. This removes the locally stored token but does not revoke it on GitHub.

To revoke the OAuth app authorization on GitHub and prevent it from being used elsewhere, follow these steps.

1. Navigate to **Settings** > **Applications** > **Authorized OAuth Apps**.
2. Navigate to your settings page:
   1. In the upper-right corner of any page on GitHub, click your profile picture.
   2. Click **Settings**.
3. In the left sidebar, click **Applications**.
4. Under **Authorized OAuth Apps**, click <svg version="1.1" width="16" height="16" viewBox="0 0 16 16" class="octicon octicon-kebab-horizontal" aria-label="The horizontal kebab icon" role="img"><path d="M8 9a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3ZM1.5 9a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Zm13 0a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z"></path></svg> next to **GitHub CLI** to expand the menu and select **Revoke**.

## Next steps

If you run into authentication problems, see [Troubleshooting GitHub Copilot CLI authentication](/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/troubleshoot-copilot-cli-auth).

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/authenticate-copilot-cli (fetched 2026-07-27) -->
