# Project Relocation Manifest

Generated from read-only dry-run audit.

## Rule

Do not move projects physically yet.
Do not delete files.
Do not push large files.
Do not break Codex / Workspace automation.

The main model is:
- one master VS Code workspace
- one GitHub control repo
- separate living project repos
- separate large local archive layer
- restore manifests for everything big or excluded

## Future target structure

J:\Setup_VcCode_Workspace\S20_Projects
- clean project folders only after separate approval

J:\Setup_VcCode_Workspace\S30_Large_Local_Archive
- raw chat jsonl
- sqlite diagnostics
- videos
- installers
- archives
- big duplicated history

J:\Setup_VcCode_Workspace\S40_Restore_Manifests
- maps of where excluded files live
- restore instructions
- checksums later if needed

## Candidate: Canada_Tax_Optimizer

Current path:
C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\Canada_Tax_Optimizer

Git:
- is Git repo
- remote: https://github.com/Incomesbook/canada-tax-optimizer.git
- changed file count from audit: 7

Large files found:
- Canada_Tax_Optimizer_ИИ_Local_CHAT_Hictory\_raw_external_ai_sessions\CODEX\codex__2025__11__20__rollout-2025-11-20T06-23-11-019aa101-0a2b-76e3-9362-dd3f9b8e1c6f.jsonl | 197.69 MB
- Canada_Tax_Optimizer_ИИ_Local_CHAT_Hictory\_raw_external_ai_sessions\CODEX\codex__2025__12__03__rollout-2025-12-03T20-14-29-019ae6ec-cc8f-7151-8ba9-452ddb8c4f9d.jsonl | 155.74 MB

Decision:
- keep as separate project repo
- do not merge into workspaces
- move later to S20_Projects only after separate cleanup
- raw chat jsonl should stay excluded or move to S30_Large_Local_Archive

## Candidate: LiveControl

Current path:
C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\LiveControl

Git:
- is Git repo
- no remote confirmed
- changed file count from audit: 3866
- last commits include chat/archive backup content

Large files found:
- G_dedup_state.sqlite | around 13920.54 MB
- G_duplicate_scan.sqlite | around 2169.64 MB
- wallet_requirements_extract.txt | around 1799.38 MB
- chat_vstav_v_osnovnoy_fail_full_rollout_2026-01-30.jsonl | around 1619.14 MB
- .git pack file | around 1078.75 MB
- CODEX raw jsonl | around 933.88 MB
- Docker Desktop Installer.exe | around 598.53 MB
- multiple additional jsonl/exe/gif/md files over 50 MB

Decision:
- do not move yet
- do not commit
- do not push
- do not merge into workspaces
- separate cleanup plan required
- likely split into:
  - source/code/docs
  - project assets
  - raw AI chat archive
  - diagnostics sqlite archive
  - installers/archive/media
  - legacy external source snapshots

## Candidate: iNCOMEBOOK

Current path:
C:\Users\IgorK\OneDrive\iNCOMEBOOK

Git:
- not a Git repo

Files:
- INCOMEBOOK.xlsm
- Copy of INCOMEBOOK.xlsm

Decision:
- legacy Excel source
- keep as archive/reference
- do not convert to Git repo now

## Next safe action

Create manifests first.
Do not physically move files until:
1. source folders are categorized
2. large files are excluded
3. restore path is clear
4. Codex/Workspace automation is protected
5. separate approval is given
