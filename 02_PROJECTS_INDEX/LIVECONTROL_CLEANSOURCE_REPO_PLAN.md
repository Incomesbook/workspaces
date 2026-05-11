# LiveControl CleanSource Separate Repo Plan

## Current status

Target:
J:\Setup_VcCode_Workspace\S20_Projects\LiveControl_CleanSource

Status:
Ready for separate Git repo planning.

Audit:
- Exists: True
- Is Git repo: False
- Files: 3009
- Size: 436.85 MB
- README.md exists: True
- .gitignore exists: True
- Files over 50 MB: none
- Blocked files/folders: none

## Recommended GitHub repo

Owner:
Incomesbook

Recommended repo name:
livecontrol-cleansource

Recommended remote URL:
https://github.com/Incomesbook/livecontrol-cleansource.git

Reason:
Use a separate project repo instead of merging into the main workspaces repo.

## Role of this repo

This repo should contain only the clean source copy of LiveControl:
- HTML
- css
- js
- DATA
- DOCS
- PROJECT_SKILLS
- resources
- .github
- .vscode
- README.md
- PROJECT_RULES.md
- .gitignore

## Must stay outside this repo

Do not add:
- old C:\ LiveControl .git history
- ARCHIVES
- _diagnostics
- _merge_backups
- LiveControl_ИИ_Local_CHAT_Hictory
- .venv
- sqlite/db/jsonl/log files
- installers
- videos
- archives
- raw AI chat history

## Execution order later

Do not run these yet without separate approval:

1. Check GitHub remote availability.
2. Create GitHub repo if it does not exist.
3. Run git init inside LiveControl_CleanSource.
4. Add remote origin.
5. Run git status and large-file check.
6. Add only clean files.
7. Commit initial clean source snapshot.
8. Push to GitHub.
9. Update workspaces manifest with repo URL.

## Current rule

No git init yet.
No push yet.
No Publish from VS Code yet.
No Sync from VS Code yet.
