# Using LSP servers with GitHub Copilot CLI

LSP servers give Copilot CLI precise code intelligence, enabling it to navigate definitions, find references, and rename symbols accurately across your project.

## Introduction

The Language Server Protocol (LSP) is an open standard used for communication between a code editor and a language server. A language server is a process that provides language-specific features like go-to-definition and renaming a code symbol across your codebase. An "LSP server" is any language server that supports the Language Server Protocol.

GitHub Copilot CLI can use LSP servers to understand the structure of your code more precisely. By adding and configuring an LSP server for each programming language in your project, you'll give Copilot CLI a better understanding of your code.

## Benefits of LSP servers

* **Accuracy**: Results come from the language's own compiler/analyzer, providing an understanding of the structure of your code. This improves Copilot's precision when it works with your code. For example, when Copilot can use "go to definition" it will find the actual definition, not a text match that looks similar.
* **Token efficiency**: Operations like "list all symbols" or "find references" return compact structured results instead of requiring the agent to read entire files into the conversation.
* **Safe refactoring**: When you rename a symbol, the LSP server reliably updates every reference across the project.
* **Speed**: Language servers index your project in the background, allowing near-instant responses.

## What LSP servers allow Copilot CLI to do

When LSP servers are available, Copilot CLI uses them automatically. You don't need to explicitly request it. Copilot CLI will use an LSP server rather than text-based search whenever it can access an LSP server for the programming language you're using.

The following language server operations are supported:

| Operation               | What it does                                                         |
| ----------------------- | -------------------------------------------------------------------- |
| Go to definition        | Jumps to where a symbol (function, class, variable) is defined.      |
| Find references         | Finds every location where a symbol is used.                         |
| Hover                   | Retrieves type information and documentation for a symbol.           |
| Rename                  | Renames a symbol across the entire project, updating all references. |
| Document symbols        | Lists all symbols defined in a file.                                 |
| Workspace symbol search | Searches for symbols by name across the project.                     |
| Go to implementation    | Finds implementations of an interface or abstract method.            |
| Incoming calls          | Shows which functions call a given function.                         |
| Outgoing calls          | Shows which functions a given function calls.                        |

Copilot selects the most appropriate LSP operation based on your prompt. For example, if you ask "where is `handlePayment` defined?", Copilot will use the go-to-definition operation.

## How to add an LSP server

For Copilot CLI to be able to use an LSP server, you must first install the server software on your local machine and then configure it in one of the configuration files that Copilot CLI reads on startup. See [Adding LSP servers for GitHub Copilot CLI](/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers).

An LSP server may also be added as part of a CLI plugin that you choose to install. A plugin might include an LSP server if, for example, it's designed to work with an uncommon programming language or a framework-specific file type. LSP servers included as part of a plugin are automatically available when you install the plugin—no additional configuration is needed. If you uninstall the plugin, the LSP server is removed. For more information, see [About GitHub Copilot plugins](/en/copilot/concepts/agents/about-plugins).

## How LSP servers are loaded

When GitHub Copilot CLI starts, it loads LSP server configurations from multiple sources with the following priority (highest to lowest):

1. **Project config**: `.github/lsp.json` in the current repository.
2. **Plugin configs**: language servers provided by installed plugins.
3. **User config**: `~/.copilot/lsp-config.json`.

Higher-priority configurations override lower-priority ones with the same server name. This means a project can customize or disable language servers for all contributors.

Once the working directory is trusted, Copilot CLI automatically starts any LSP servers that are relevant to your project, in the background, so they are ready to respond immediately when needed.

## Next steps

* [Adding LSP servers for GitHub Copilot CLI](/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers)

## Further reading

* [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) on the Microsoft website
* [GitHub Copilot CLI command reference](/en/copilot/reference/copilot-cli-reference/cli-command-reference)

<!-- source: https://docs.github.com/en/copilot/concepts/agents/copilot-cli/lsp-servers (fetched 2026-07-27) -->
