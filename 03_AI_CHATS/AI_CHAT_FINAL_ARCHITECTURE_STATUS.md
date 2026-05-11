# AI Chat Final Architecture Status

Current safe architecture:

1. Local raw layer:
   J:\_AI_CHATS_ОБЩИЕ\_SOURCES

2. Backup-before-overwrite layer:
   J:\_AI_CHATS_ОБЩИЕ\_BACKUPS_BEFORE_OVERWRITE

3. GitHub control/manifest layer:
   Incomesbook/workspaces

4. Weekly tasks:
   - AI Chat Weekly Local Raw Mirror
   - AI Chat Weekly Manifest Only Sync

Raw chats are stored locally only.
GitHub receives manifests/control docs only unless Igor separately approves raw GitHub sync.