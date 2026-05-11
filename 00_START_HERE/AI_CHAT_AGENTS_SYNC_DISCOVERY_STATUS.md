# AI Chat Agents Sync Discovery Status

Mode: NO-DELETE / NO-ARCHIVE CONTROL MODE.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## Hard rules

- Do not delete user files, chats, projects, archives, backups, reports, or legacy folders.
- Do not delete anything unless it was clearly created by the current script as a temporary/stage/test file.
- Do not copy or move C:\Users\IgorK\.claude or C:\Users\IgorK\.codex without a separate approved copy plan.
- Do not enable Git LFS, archive execution, password prompts, scheduled tasks, ENV/PATH changes, or protected S06 automation changes without explicit approval.
- Do not push raw chats to GitHub until raw-chat safety, size, and secret gates are explicitly approved.

## Confirmed root summary

- Primary common root: J:\_AI_CHATS_ОБЩИЕ
- Existing common roots: 
- J:\_AI_CHATS_ОБЩИЕ
- ClaudeData target exists: 
- True
- ClaudeHub exists: 
- True
- C Claude source exists: 
- True
- C Codex source exists: 
- True
- CODEX_HOME: 
- J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE
- CLAUDE_CONFIG_DIR: 
- J:\ClaudeData\.claude

## Detected agents with counted files

- CherryStudio
- Claude
- ClaudeDesktop
- Codex
- Common

## Sources needing read-only copy/sync plan before any copying

- CherryStudio | Roaming CherryStudio | C:\Users\IgorK\AppData\Roaming\CherryStudio | counted=124
- Claude | CLAUDE_CONFIG_DIR User | J:\ClaudeData\.claude | counted=2
- Claude | ClaudeHub | J:\ClaudeHub | counted=3
- Claude | J Claude config target | J:\ClaudeData\.claude | counted=2
- Claude | J Claude memory | J:\ClaudeData\memory | counted=1
- Claude | User .claude IgorK | C:\Users\IgorK\.claude | counted=365
- ClaudeDesktop | Local Claude | C:\Users\IgorK\AppData\Local\Claude | counted=1
- ClaudeDesktop | Roaming Claude | C:\Users\IgorK\AppData\Roaming\Claude | counted=1
- Codex | CODEX_HOME User | J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE | counted=7682
- Codex | User .codex | C:\Users\IgorK\.codex | counted=3841
- Codex | Workspace Codex live | J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE | counted=7682

## Large or capped roots requiring caution

- Codex | C:\Users\IgorK\.codex | *.jsonl | count=214 | sizeMB=9502.56 | capped=False
- Codex | C:\Users\IgorK\.codex | *.md | count=3001 | sizeMB=16.79 | capped=True
- Codex | J:\_AI_CHATS_ОБЩИЕ\CODEX | *.jsonl | count=214 | sizeMB=9502.56 | capped=False
- Codex | J:\_AI_CHATS_ОБЩИЕ\CODEX | *.md | count=3001 | sizeMB=16.79 | capped=True
- Codex | J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE | *.jsonl | count=214 | sizeMB=9502.56 | capped=False
- Codex | J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE | *.md | count=3001 | sizeMB=16.79 | capped=True
- Common | J:\_AI_CHATS_ОБЩИЕ | *.jsonl | count=282 | sizeMB=9674.78 | capped=False
- Common | J:\_AI_CHATS_ОБЩИЕ | *.md | count=3001 | sizeMB=78.26 | capped=True

## GitHub weekly sync decision

Weekly raw chat sync to GitHub is not enabled here.

Allowed now:
- GitHub control docs
- manifests
- pointers
- dry-run plans

Blocked until explicit approval:
- raw chat GitHub sync
- scheduled task creation
- deletion
- archive execution
- password prompt
- ENV/PATH changes