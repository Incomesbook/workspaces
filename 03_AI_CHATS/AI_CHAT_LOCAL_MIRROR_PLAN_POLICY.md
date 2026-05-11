# AI Chat Local Mirror Plan Policy

Mode: POLICY ONLY.

## Rules

- Never delete originals.
- Never move originals.
- Never overwrite existing files without versioning.
- Never copy raw chats without explicit approval.
- Never sync raw chats to GitHub without a separate raw sync approval.
- Never enable scheduled tasks without explicit approval.
- Native agent roots such as .claude and .codex require secret gate.
- Large/capped roots require size gate.
- Extension install folders are reference-only, not chat history.

## Future local mirror target pattern

J:\_AI_CHATS_ОБЩИЕ\_SOURCES\<Agent>_<Role>\...

## Current action

Plan only.
No copy.
No delete.
No schedule.