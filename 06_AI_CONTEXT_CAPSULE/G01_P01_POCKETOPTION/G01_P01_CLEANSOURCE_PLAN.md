# G01 P01 Clean Source Plan

## Project

G01_P01_PocketOption

## Local path

J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P01_PocketOption

## Purpose

This is a GitHub-safe planning file only.

It records what the clean-source candidate audit found and defines the next safe direction.

No raw project files are copied here.
No files are moved.
No files are deleted.
No Git repo is initialized inside G01_P01.

## Latest clean-source candidate audit

Report:
J:\_AI_CHATS_ОБЩИЕ\_AUDIT\G01_P01_CLEANSOURCE_CANDIDATE_AUDIT_20260511_063627.md

## Audit conclusion

The audit was useful, but the current POSSIBLE_CLEAN_SOURCE pool is not clean enough to copy directly.

Reason:
The candidate list still includes:
- runtime JSON outputs
- paper_scanner artifacts
- shadow artifacts
- duplicated legacy Imported_From_G01_P03 material
- browser/profile adjacent files
- generated scan outputs
- PocketOption runtime artifacts

Therefore, do not copy POSSIBLE_CLEAN_SOURCE blindly.

## Known dangerous areas

Do not include in normal Git or CleanSource copy:

- chrome_profile
- Cache
- Code Cache
- GPUCache
- IndexedDB
- Local Storage
- Session Storage
- Extension State
- Network
- WebStorage
- Sync Data
- TrustTokenKeyCommitments
- G01_P01_02_05_AI_Memory
- G01_P01_02_06_Data
- G01_P01_02_07_Results
- G01_P01_02_08_Logs
- G01_P01_02_10_Tech
- G01_P01_02_03_05_API_Keys_And_IDs
- G01_P01_02_03_06_External_Memory
- NotebookLM_Staging
- 10_Артефакты
- paper_scanner
- shadow
- runtime_common
- __pycache__
- node_modules
- .venv
- .git

## Clean-source rule

A G01_P01 clean-source extraction must start with the smallest safe layer.

Candidate clean-source priority:
1. project skills
2. workflow/rules markdown
3. selected automation scripts
4. selected source code only after excluding artifacts/runtime/browser profile
5. selected docs that do not contain private/API/browser/chat state

Do not include in first clean-source copy:
- Chrome profile
- ChatGPT IndexedDB
- browser extension runtime state
- AI memory
- raw chat exports
- .jsonl
- logs
- runtime results
- scan outputs
- paper_scanner outputs
- shadow outputs
- cache files
- API/key/private folders
- installers
- PDFs
- mp3/audio
- archives
- legacy browser-state folders

## Possible future candidate folders

Review later, not auto-approved:

- G01_P01_02_Project_Settings\G01_P01_02_09_Tools
- G01_P01_02_Project_Settings\G01_P01_02_09_Tools\G01_P01_02_09_01_PROJECT_SKILLS
- G01_P01_02_Project_Settings\G01_P01_02_09_Tools\G01_P01_02_09_04_Automation_Scripts
- selected source code from Agent_PocketOption_VcCode_V1 after excluding:
  - 10_Артефакты
  - chrome_profile
  - paper_scanner
  - shadow
  - runtime outputs
  - cache
  - logs
  - private/API/browser state

## Large/archive policy

Already documented in:
G01_P01_LARGE_PRIVATE_CHAT_MANIFEST.md

Do not duplicate raw large files into the workspaces repo.

## Next safe action

Create a stricter read-only CSV plan generator.

The generator should:
- produce CSV only
- not copy files
- not move files
- not delete files
- not git-init
- include only strict clean-source candidates
- exclude Chrome profile/cache/IndexedDB/browser state
- exclude AI memory, logs, results, data, private/API folders
- exclude 10_Артефакты, paper_scanner, shadow, runtime_common
- report total count and MB
- report any target collisions
- report any file over 10 MB for manual review

## Future target if later approved

J:\Setup_VcCode_Workspace\S20_Projects\G01_P01_PocketOption_CleanSource

Not approved yet.

## Current decision

Plan only.
No copy yet.
No move yet.
No new repo yet.
No push of G01_P01 raw project.
