# LiveControl Clean Source Plan

Generated from corrected read-only classification.

## Rule

Do not move LiveControl yet.
Do not delete files.
Do not commit LiveControl.
Do not push LiveControl.
Do not merge LiveControl into workspaces.

## Corrected classification result

SOURCE_CANDIDATE_OK:
- 3008 files
- 437.94 MB
- candidate source/project material

SOURCE_CANDIDATE_LARGE_REVIEW:
- 1 file
- 46.97 MB
- resources\main_page\nav_images\logo_exact_vector_nobg.svg
- needs manual review before Git

UNCLASSIFIED_REVIEW:
- 964 files
- 530.1 MB
- needs separate review before any move

EXCLUDE_ARCHIVE_RUNTIME_HISTORY:
- 17284 files
- 50574.29 MB
- must stay outside normal GitHub Git

EXCLUDE_BINARY_MEDIA_INSTALLER:
- 17 files
- 405.74 MB
- must stay outside normal GitHub Git

## Source candidate folders

These are the only folders allowed as first clean-project candidates:

- HTML
- css
- js
- DATA
- DOCS
- PROJECT_SKILLS
- resources
- .github
- .vscode
- PROJECT_RULES.md

## Excluded folders and patterns

Never push directly to normal Git:

- ARCHIVES
- _diagnostics
- _merge_backups
- LiveControl_ИИ_Local_CHAT_Hictory
- .venv
- .git
- *.sqlite
- *.db
- *.jsonl
- *.log
- *.exe
- *.msi
- *.zip
- *.7z
- *.rar
- *.mp4
- *.mov
- *.avi
- *.webm

## Biggest excluded examples

- G_dedup_state.sqlite around 13920.54 MB
- G_duplicate_scan.sqlite around 2169.64 MB
- wallet_requirements_extract.txt around 1799.38 MB
- chat_vstav_v_osnovnoy_fail_full_rollout_2026-01-30.jsonl around 1619.14 MB
- .git pack file around 1078.75 MB
- CODEX raw jsonl around 933.88 MB
- Docker Desktop Installer.exe around 598.53 MB

## Decision

LiveControl must be split later into:

1. Clean source project
2. Review-needed assets
3. Large local archive
4. Raw AI chat archive
5. Diagnostics archive
6. Installer/media archive
7. Restore manifest

## Next safe action

Create a read-only copy plan for SOURCE_CANDIDATE_OK only.
Do not execute copy/move yet.
