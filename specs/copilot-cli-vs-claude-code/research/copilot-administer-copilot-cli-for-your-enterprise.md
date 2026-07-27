# Administering Copilot CLI for your enterprise

Control the use of Copilot CLI within your enterprise.

Copilot CLI brings agentic capabilities to developers' command line. When Copilot CLI is enabled, developers can use it to ask Copilot to work on tasks locally or delegate work to Copilot cloud agent.

## Enabling or disabling Copilot CLI

You can control the use of Copilot CLI by configuring a policy.

1. Navigate to your enterprise. For example, from the [Enterprises](https://github.com/settings/enterprises?ref_product=ghec\&ref_type=engagement\&ref_style=text) page on GitHub.com.
2. At the top of the page, click **<svg version="1.1" width="16" height="16" viewBox="0 0 16 16" class="octicon octicon-copilot" aria-label="copilot" role="img"><path d="M7.998 15.035c-4.562 0-7.873-2.914-7.998-3.749V9.338c.085-.628.677-1.686 1.588-2.065.013-.07.024-.143.036-.218.029-.183.06-.384.126-.612-.201-.508-.254-1.084-.254-1.656 0-.87.128-1.769.693-2.484.579-.733 1.494-1.124 2.724-1.261 1.206-.134 2.262.034 2.944.765.05.053.096.108.139.165.044-.057.094-.112.143-.165.682-.731 1.738-.899 2.944-.765 1.23.137 2.145.528 2.724 1.261.566.715.693 1.614.693 2.484 0 .572-.053 1.148-.254 1.656.066.228.098.429.126.612.012.076.024.148.037.218.924.385 1.522 1.471 1.591 2.095v1.872c0 .766-3.351 3.795-8.002 3.795Zm0-1.485c2.28 0 4.584-1.11 5.002-1.433V7.862l-.023-.116c-.49.21-1.075.291-1.727.291-1.146 0-2.059-.327-2.71-.991A3.222 3.222 0 0 1 8 6.303a3.24 3.24 0 0 1-.544.743c-.65.664-1.563.991-2.71.991-.652 0-1.236-.081-1.727-.291l-.023.116v4.255c.419.323 2.722 1.433 5.002 1.433ZM6.762 2.83c-.193-.206-.637-.413-1.682-.297-1.019.113-1.479.404-1.713.7-.247.312-.369.789-.369 1.554 0 .793.129 1.171.308 1.371.162.181.519.379 1.442.379.853 0 1.339-.235 1.638-.54.315-.322.527-.827.617-1.553.117-.935-.037-1.395-.241-1.614Zm4.155-.297c-1.044-.116-1.488.091-1.681.297-.204.219-.359.679-.242 1.614.091.726.303 1.231.618 1.553.299.305.784.54 1.638.54.922 0 1.28-.198 1.442-.379.179-.2.308-.578.308-1.371 0-.765-.123-1.242-.37-1.554-.233-.296-.693-.587-1.713-.7Z"></path><path d="M6.25 9.037a.75.75 0 0 1 .75.75v1.501a.75.75 0 0 1-1.5 0V9.787a.75.75 0 0 1 .75-.75Zm4.25.75v1.501a.75.75 0 0 1-1.5 0V9.787a.75.75 0 0 1 1.5 0Z"></path></svg> AI controls**.
3. To manage policies for **Copilot**, in the sidebar, click <svg version="1.1" width="16" height="16" viewBox="0 0 16 16" class="octicon octicon-copilot" aria-label="copilot" role="img"><path d="M7.998 15.035c-4.562 0-7.873-2.914-7.998-3.749V9.338c.085-.628.677-1.686 1.588-2.065.013-.07.024-.143.036-.218.029-.183.06-.384.126-.612-.201-.508-.254-1.084-.254-1.656 0-.87.128-1.769.693-2.484.579-.733 1.494-1.124 2.724-1.261 1.206-.134 2.262.034 2.944.765.05.053.096.108.139.165.044-.057.094-.112.143-.165.682-.731 1.738-.899 2.944-.765 1.23.137 2.145.528 2.724 1.261.566.715.693 1.614.693 2.484 0 .572-.053 1.148-.254 1.656.066.228.098.429.126.612.012.076.024.148.037.218.924.385 1.522 1.471 1.591 2.095v1.872c0 .766-3.351 3.795-8.002 3.795Zm0-1.485c2.28 0 4.584-1.11 5.002-1.433V7.862l-.023-.116c-.49.21-1.075.291-1.727.291-1.146 0-2.059-.327-2.71-.991A3.222 3.222 0 0 1 8 6.303a3.24 3.24 0 0 1-.544.743c-.65.664-1.563.991-2.71.991-.652 0-1.236-.081-1.727-.291l-.023.116v4.255c.419.323 2.722 1.433 5.002 1.433ZM6.762 2.83c-.193-.206-.637-.413-1.682-.297-1.019.113-1.479.404-1.713.7-.247.312-.369.789-.369 1.554 0 .793.129 1.171.308 1.371.162.181.519.379 1.442.379.853 0 1.339-.235 1.638-.54.315-.322.527-.827.617-1.553.117-.935-.037-1.395-.241-1.614Zm4.155-.297c-1.044-.116-1.488.091-1.681.297-.204.219-.359.679-.242 1.614.091.726.303 1.231.618 1.553.299.305.784.54 1.638.54.922 0 1.28-.198 1.442-.379.179-.2.308-.578.308-1.371 0-.765-.123-1.242-.37-1.554-.233-.296-.693-.587-1.713-.7Z"></path><path d="M6.25 9.037a.75.75 0 0 1 .75.75v1.501a.75.75 0 0 1-1.5 0V9.787a.75.75 0 0 1 .75-.75Zm4.25.75v1.501a.75.75 0 0 1-1.5 0V9.787a.75.75 0 0 1 1.5 0Z"></path></svg> **Copilot**.
4. In the "Copilot Clients" section, for Copilot CLI, select your preferred policy.

## How do other AI controls affect Copilot CLI?

Not all enterprise-level AI controls and policies apply to Copilot CLI. These are the controls that **do apply**:

### Copilot CLI enablement

You can enable or disable Copilot CLI at the enterprise or organization level.

### Model selection

Users can only access AI models that are enabled at the enterprise level. When you enable or disable models in your enterprise settings, those changes are reflected in Copilot CLI. Users can view which models are available to them using the `/model` command.

Enterprise and organization owners can provide keys for custom models. Users can select these like any other model: with the Copilot CLI model selector, the `--model` flag, or environment variables. See [Enabling custom models for GitHub Copilot in your enterprise](/en/copilot/how-tos/administer-copilot/manage-for-enterprise/use-your-own-api-keys).

Separately, users can also provide their own LLM keys locally. This is not controlled by enterprise policies. See [Using your own LLM models in GitHub Copilot CLI](/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models).

### Custom agents

Enterprise-configured custom agents are available to use with Copilot CLI.

### MCP server policies

Enterprise and organization MCP policies apply to Copilot CLI. You can configure an MCP registry URL so developers can discover approved servers, and set an allowlist policy to restrict which MCP servers can run. For more information, see [Configure MCP server access for your organization or enterprise](/en/copilot/how-tos/administer-copilot/manage-mcp-usage/configure-mcp-server-access).

### Copilot cloud agent enablement

Both the Copilot CLI policy and the Copilot cloud agent policy must be enabled for users to be able to use the `/delegate` command in Copilot CLI.

### Audit logging

Updates to enterprise policies that affect Copilot CLI are recorded as events in the enterprise audit log.

### Seat assignment

Users must have an assigned GitHub Copilot seat to access Copilot CLI.

### Controls that do not apply

All other controls do **not** affect Copilot CLI, notably:

* **IDE-specific policies**: Policies configured for specific IDEs or editor extensions
* **Content exclusions**: File path-based content exclusions

## Why can't my developers access Copilot CLI?

If you expect a user to have access to Copilot CLI and they don't:

1. Ensure the user has a valid GitHub Copilot seat assignment from an organization in your enterprise.
2. Verify the **enterprise-level policy.** If you set the policy to "Enabled everywhere" or "Disabled everywhere," this overrides all organization-level settings.
3. If the enterprise policy is set to "Let organizations decide," check the organizations where the user receives their GitHub Copilot license. Copilot CLI must be enabled in **at least one** of the organization granting them a GitHub Copilot license.

One way to ensure consistent access across all organizations is to set the policy to **Enabled everywhere** at the enterprise level.

## Further reading

* [Best practices for GitHub Copilot CLI](/en/copilot/how-tos/copilot-cli/cli-best-practices)

<!-- source: https://docs.github.com/en/copilot/how-tos/copilot-cli/administer-copilot-cli-for-your-enterprise (fetched 2026-07-27) -->
