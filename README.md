# Claude Workshop

Configuration and scripts for running [Claude Code](https://docs.anthropic.com/en/docs/claude-code) against alternative backends.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (`npm install -g @anthropic-ai/claude-code`)
- Docker and Docker Compose (for LiteLLM)

---

## Option 1: Databricks

This guide walks through a practical, end-to-end setup: installing Claude Code, wiring it to Anthropic models served from Databricks, and configuring authentication so everything "just works" from your terminal and editor. You'll generate model-scoped API keys, plug them into Claude's settings, bypass the default login flow for a smoother developer experience, and finish by testing the workflow directly from the CLI and VS Code.

### 1. Install Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### 2. Generate API keys from Databricks

1. Log in to your Databricks workspace.
2. Click **Serving** under the **AI/ML** section (bottom-left corner).
3. Click **Integrate coding agents → Get Started**.
4. Select **Other integrations**.
5. Select **Claude Code** as the coding integration.
6. Select the **Default Anthropic Model** and other desired options.
7. Click **Generate API Keys** and note the API key and base URL shown.

### 3. Update Claude Code settings

Go to `~/.claude/settings.json` and update/replace with the keys generated in the previous step:

```json
{
  "env": {
    "ANTHROPIC_MODEL": "databricks-claude-sonnet-4-6",
    "ANTHROPIC_BASE_URL": "https://<workspace-host>/serving-endpoints/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-databricks-token>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "databricks-claude-opus-4-6",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "databricks-claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "databricks-claude-haiku-4-5",
    "ANTHROPIC_CUSTOM_HEADERS": "x-databricks-use-coding-agent-mode: true",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  }
}
```

### 4. Override the login method

Update/create `~/.claude/settings.json` with the following value. This prevents Claude from prompting you to select a login method:

```json
{
  "env": {
    "ANTHROPIC_MODEL": "databricks-claude-sonnet-4-6",
    "ANTHROPIC_BASE_URL": "https://<workspace-host>/serving-endpoints/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-databricks-token>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "databricks-claude-opus-4-6",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "databricks-claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "databricks-claude-haiku-4-5",
    "ANTHROPIC_CUSTOM_HEADERS": "x-databricks-use-coding-agent-mode: true",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  },
  "forceLoginMethod": "console"
}
```

### 5. Install the Claude Code VS Code extension

Install the [Claude Code extension](https://marketplace.visualstudio.com/items?itemName=Anthropic.claude-code) from the VS Code marketplace. It picks up the same `~/.claude/settings.json` configuration automatically.

### 6. Test the setup

Type `claude` and press Enter:

```bash
claude
```

Claude Code will connect to the Databricks-hosted model specified by `ANTHROPIC_BASE_URL`.

---

## Option 2: LiteLLM Proxy (GitHub Copilot backend)

The LiteLLM proxy in this repo translates Anthropic API calls into GitHub Copilot model requests, exposing the following model aliases:

| Model alias | Upstream model |
|---|---|
| `claude-sonnet-4-6` | `github_copilot/claude-sonnet-4.6` |
| `claude-opus-4-6` | `github_copilot/claude-opus-4.6` |
| `claude-haiku-4-5` | `github_copilot/claude-haiku-4.5` |

### Start the proxy

```bash
./litellm.sh start    # start in background (port 4000)
./litellm.sh status   # check container status
./litellm.sh log      # tail logs
./litellm.sh stop     # stop
```

### Configure Claude Code

```bash
export ANTHROPIC_BASE_URL="http://localhost:4000"
export ANTHROPIC_API_KEY="changeme"   # LiteLLM accepts any non-empty value
```

### Launch Claude Code with a specific model

```bash
claude --model claude-sonnet-4-6
```

The model name must match one of the `model_name` entries in [`litellm/config.yaml`](litellm/config.yaml).

### GitHub Copilot credentials

The proxy reads GitHub Copilot auth from `litellm/auth/github_copilot/`. Keep those files up to date if your Copilot token expires.

---

## Environment variable reference

| Variable | Purpose |
|---|---|
| `ANTHROPIC_BASE_URL` | Override the Anthropic API base URL (Databricks endpoint or `http://localhost:4000` for LiteLLM) |
| `ANTHROPIC_API_KEY` | Databricks PAT, or any non-empty string when using LiteLLM |
