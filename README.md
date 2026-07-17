# Graphify — quick install

Turn any folder of code, docs, or papers into a navigable knowledge graph you can
query, right inside Claude Code. This installs the `graphify` CLI **and** the
`/graphify` skill in one step.

## Install (one line)

```bash
curl -LsSf https://raw.githubusercontent.com/abedkamed-dev/graphify-installer/main/install-graphify.sh | bash
```

That's the whole thing. It:
1. installs [`uv`](https://docs.astral.sh/uv/) if it's missing (brings its own Python — nothing to set up),
2. installs the `graphify` CLI (with SQL-schema parsing, so DB migrations get graphed too),
3. installs the `/graphify` skill for Claude Code,
4. runs a smoke test to confirm it works.

Re-running just upgrades everything in place — it's safe.

### Prefer not to pipe to bash?

Download and read it first, then run:

```bash
curl -LsSfO https://raw.githubusercontent.com/abedkamed-dev/graphify-installer/main/install-graphify.sh
less install-graphify.sh          # inspect it
chmod +x install-graphify.sh && ./install-graphify.sh
```

## Requirements
- macOS or Linux
- [Claude Code](https://claude.com/claude-code) — the `/graphify` skill installs into `~/.claude/skills`
- `curl` (used to fetch `uv` if you don't have it)

## Use it

Open Claude Code in any project folder and type:

```
/graphify .
```

You'll get three outputs in `graphify-out/`:
- `graph.html` — an interactive graph, open in any browser
- `GRAPH_REPORT.md` — an audit report (core abstractions, surprising links, questions)
- `graph.json` — the raw graph data

Then just ask questions in plain language — e.g. *"How does auth flow through the app?"* —
and it answers from the graph.

## Notes
- If a new terminal can't find `graphify`, add this to your `~/.zshrc` (or `~/.bashrc`):
  ```bash
  . "$HOME/.local/bin/env"
  ```
- Graphify needs **no API key**. Code is parsed structurally; only docs/images use an
  LLM, and it uses the agent you're already running.

