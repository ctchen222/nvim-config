# CodeCompanion Chat UI Design

## Goal

Improve the CodeCompanion ACP chat buffer while keeping agent activity visible:
reasoning remains available but is folded after a response, and the chat becomes
quieter to read. Local `agent.md` files should be loaded automatically together
with CodeCompanion's existing default rule files.

## Design

- Keep reasoning enabled and folded by default.
- Hide per-response token counts and keep tool-processing messages enabled.
- Use concise `Codex` and `You` chat roles.
- Keep Markview rendering, enable CodeCompanion's message header separators,
  and use a slightly wider vertical chat window with a rounded border.
- Add a dedicated `local_agent` rule group for `agent.md`, autoloaded alongside
  the built-in `default` group. Existing `AGENT.md` and `AGENTS.md` support is
  retained through the built-in group.

## Scope

Only CodeCompanion configuration and its theme highlight overrides are changed.
Existing unrelated working-tree changes are not staged or modified.

## Verification

- Parse the changed Lua files with Neovim's headless mode.
- Load the CodeCompanion plugin specification and confirm the configured UI and
  rules values.
