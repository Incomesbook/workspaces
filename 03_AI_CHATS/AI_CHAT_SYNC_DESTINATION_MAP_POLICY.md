# AI Chat Sync Destination Map Policy

Mode: POLICY ONLY.

## Target common root

J:\_AI_CHATS_ОБЩИЕ

## Destination rule

Future approved copies must use this structure:

J:\_AI_CHATS_ОБЩИЕ\_SOURCES\<Agent>_<Role>\...

## Required protections

- Never delete originals.
- Never overwrite without backup/versioning.
- Never copy without explicit approval.
- Never sync extension install folders as chat history.
- Large/capped roots require size gate.
- Native agent roots such as .claude and .codex require secret gate.
- Raw GitHub push requires separate approval.

## Current action

Manifest only.
No copy.
No delete.
No schedule.