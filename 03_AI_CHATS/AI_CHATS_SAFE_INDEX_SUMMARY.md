# AI Chats Safe Index Summary
Generated: 2026-05-11 04:54:14

## Purpose
This is a GitHub-safe metadata summary only. It does not contain raw chat content, credentials, tokens, passwords, or API keys.

## V2 filter note
V2 ignores common VS Code extension/recovery/dependency noise such as node_modules, typeshed, Python stubs, VSCode-Recovery, and workspaceStorage_before_merge.

## Totals
- Likely chat/runtime metadata rows: 125936
- Total MB represented: 169910.98
- Files needing LFS/archive by size: 468
- Strict secret-like filenames excluded from summary: 382
- Noise files ignored: 381352

## Summary by system
| System | Files | MB | Needs LFS/archive |
|---|---:|---:|---:|
| AI_COMMON | 4306 | 10029.32 MB | 26 |
| S08_GLOBAL_AI_CHATS | 94271 | 118240.64 MB | 329 |
| CLAUDE_USERPROFILE | 367 | 98.63 MB | 0 |
| CLAUDE_ROAMING | 1 | 0 MB | 0 |
| CLAUDE_LOCAL | 1 | 0 MB | 0 |
| VSCODE_SHARED | 26990 | 41542.39 MB | 113 |

## Decision
- Normal GitHub repo stores this summary, plans, scripts, and AI Context Capsules.
- Raw large chat files are not pushed yet.
- Strict secret-like files are excluded from the GitHub-safe summary.
- Next step: build project-level AI Context Capsules and export/import checklist.
