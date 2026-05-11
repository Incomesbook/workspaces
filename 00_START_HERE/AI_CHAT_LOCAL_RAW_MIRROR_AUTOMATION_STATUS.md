# AI Chat Local Raw Mirror Automation Status

Mode: LOCAL RAW MIRROR AUTOMATION CONFIGURED.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## What this adds

- Local raw mirror worker: tools/local-ai-chat-raw-mirror.ps1
- Local raw mirror target: J:\_AI_CHATS_ОБЩИЕ\_SOURCES
- Backup-before-overwrite root: J:\_AI_CHATS_ОБЩИЕ\_BACKUPS_BEFORE_OVERWRITE
- Weekly scheduled task: AI Chat Weekly Local Raw Mirror

## Safety

- No deletion.
- No move.
- No raw GitHub push.
- No Git LFS.
- No archive/password.
- No ENV/PATH change.
- Original C:\ and J:\ agent roots remain untouched.
- Changed destination files are backed up before overwrite.

## Schedule

Task name: AI Chat Weekly Local Raw Mirror
Frequency: weekly
Day: SUN
Time: 17:30