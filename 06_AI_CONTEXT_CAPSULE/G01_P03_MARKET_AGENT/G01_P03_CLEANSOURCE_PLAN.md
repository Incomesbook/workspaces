# G01 P03 Clean Source Plan

## Project

G01_P03_Агент_Анализа_Рынков

## Local path

J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P03_Агент_Анализа_Рынков

## Purpose

This is a GitHub-safe planning file only.

It records what the clean-source candidate audit found and defines the next safe direction.

No raw project files are copied here.
No files are moved.
No files are deleted.
No Git repo is initialized inside G01_P03.

## Latest clean-source candidate audit

Report:
J:\_AI_CHATS_ОБЩИЕ\_AUDIT\G01_P03_CLEANSOURCE_CANDIDATE_AUDIT_20260511_054842.md

## Audit summary

| Category | Files | MB | Meaning |
|---|---:|---:|---|
| EXCLUDE_OR_ARCHIVE | 2590 | 3914.88 | Must not go to normal Git without archive/LFS/private decision |
| POSSIBLE_CLEAN_SOURCE | 2087 | 186.38 | Candidate pool only, not auto-approved |
| REVIEW | 39 | 2.23 | Needs manual classification |

## Important conclusion

The audit is good enough to continue, but it is not safe to copy all POSSIBLE_CLEAN_SOURCE blindly.

Reason:
The possible source pool includes:
- large .txt knowledge files
- duplicated market analysis instruction files
- web capture HTML/CSS/images
- NotebookLM staging manifests
- screenshots and trading reference images
- selected docs and automation scripts

Some of these are source/knowledge, but some are generated captures or duplicated research archives.

## Clean-source rule

A clean-source extraction should start with the smallest safe layer:

Candidate clean-source priority:
1. automation scripts
2. project skills
3. small markdown/txt rules and indexes
4. selected HTML/CSS/JS if they are actual project source, not web captures
5. selected docs that do not contain private/API data
6. selected small images only if needed for project understanding

Do not include in first clean-source copy:
- AI memory
- Claude/Codex/Copilot raw exports
- .jsonl
- logs
- runtime results
- data outputs
- installers
- PDFs
- mp3/audio
- zip/dmg/msi/msix/exe
- API/key/private folders
- caches
- web capture folders unless manually approved
- NotebookLM staging dumps unless manually approved

## Candidate folders for later review

Potentially useful:
- G01_P03_01_Project
- G01_P03_02_Project_Settings\G01_P03_02_09_Tools\G01_P03_02_09_01_PROJECT_SKILLS
- G01_P03_02_Project_Settings\G01_P03_02_09_Tools\G01_P03_02_09_04_Automation_Scripts
- selected files from G01_P03_02_Project_Settings\G01_P03_02_04_Knowledge
- selected project notes and rules

High-risk or excluded:
- G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_And_Service_References
- G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_Keys_And_IDs
- G01_P03_02_Project_Settings\G01_P03_02_05_AI_Memory
- G01_P03_02_Project_Settings\G01_P03_02_06_Data
- G01_P03_02_Project_Settings\G01_P03_02_07_Results
- G01_P03_02_Project_Settings\G01_P03_02_08_Logs
- G01_P03_02_Project_Settings\G01_P03_02_10_Tech
- G01_P03_02_Project_Settings\G01_P03_02_11_Legacy
- G01_P03_01_Project\_AI_INBOX

## Large/archive policy

Already documented in:
G01_P03_LARGE_PRIVATE_CHAT_MANIFEST.md

Do not duplicate raw large files into the workspaces repo.

## Next safe action

Create a stricter read-only copy-plan generator.

The generator should:
- produce CSV only
- not copy files
- not move files
- not delete files
- not git-init
- include only strict clean-source candidates
- exclude web captures, NotebookLM staging, AI memory, logs, results, data, private/API folders, installers, audio, PDFs, archives
- report total count and MB
- report any target collisions
- report any file over 10 MB for manual review

## Future target if later approved

J:\Setup_VcCode_Workspace\S20_Projects\G01_P03_MarketAgent_CleanSource

Not approved yet.

## Current decision

Plan only.
No copy yet.
No move yet.
No new repo yet.
No push of G01_P03 raw project.
