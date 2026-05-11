# AI Chat Auto Local Raw Mirror Status

Mode: ACTIVE AUTOMATIC LOCAL RAW MIRROR.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## Active tasks

- AI Chat Auto Local Raw Mirror 30min: every 30 minutes
- AI Chat Auto Local Raw Mirror Logon: at Windows logon

## Worker

tools/auto-ai-chat-local-raw-mirror.ps1

## Target

J:\_AI_CHATS_ОБЩИЕ\_SOURCES

## Scope

Static known AI roots plus dynamic keyword discovery in:
- C:\Users\IgorK\AppData\Roaming
- C:\Users\IgorK\AppData\Local
- C:\Users\IgorK
- J:\Setup_VcCode_Workspace
- J:\ClaudeData
- J:\

## Safety

- No deletion.
- No move.
- No raw GitHub push.
- No Git LFS.
- Manifest/status/control docs only in GitHub.