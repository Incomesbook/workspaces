# G01 Risk and Backup Decision Matrix

## Purpose

This matrix defines how to handle each G01_All_About_Trading top-level folder before any GitHub publishing, sync, move, or cleanup.

Rule:
Do not push G01 root as one repo.
Do not run git add . inside G01.
Handle subproject-by-subproject.

## Current confirmed state

G01 root:
J:\ПРОЕКТЫ\G01_All_About_Trading

Git repo:
False

Latest subproject map commit:
55fafc4 Add G01 subprojects map

## Decision matrix

| Folder | Size MB | AI memory | API/key-like | Large >50MB | Current decision | Future action |
|---|---:|---:|---:|---:|---|---|
| .github | 0 | False | False | False | safe metadata candidate | keep as reference only |
| .project_skills | 0 | False | False | False | safe metadata candidate | review later |
| .vscode | 0 | False | False | False | safe config candidate | review settings before sharing |
| AI_AGENT_ARTIFACTS | 10.79 | True | False | False | capsule/index candidate | create manifest, do not raw-push blindly |
| ARCHIVES | 791.08 | False | False | True | archive-only | do not push normal Git |
| CODE | 0.01 | False | False | False | possible future repo candidate | audit first |
| DATA | 1.03 | False | False | False | data manifest candidate | review for private/source data |
| DOCS | 3.24 | False | False | False | docs candidate | review for private info |
| G01_01_Group_Settings | 3471.31 | True | True | True | protected/private-heavy | never push blindly |
| G01_P01_PocketOption | 2269.73 | True | True | True | protected trading project | capsule first, then manifest/LFS review |
| G01_P02_TradingView_Claude | 406.91 | True | True | False | protected trading project | capsule first, review API/private folders |
| G01_P03_Агент_Анализа_Рынков | 4103.44 | True | True | True | high-priority protected project | capsule first, large/chat manifest next |
| G01_P04_Telegram_run_trade_paper_Alpaca | 6.54 | True | True | False | protected trading automation | capsule first, private review |
| G01_P05_AllWedSources_Technical_Analysis | 0.02 | True | True | False | source/research project | capsule first |
| G01_P06_SourcesIFO_SotialMedia | 0.01 | True | True | False | source/research project | capsule first |
| G01_P07_SourcesIFO_Youtube | 0.01 | True | True | False | source/research project | capsule first |
| G01_P08_Copy_Trading | 0.01 | True | True | False | protected trading project | capsule first |
| HTML | 22.66 | False | False | False | possible asset/source candidate | review before publishing |

## Priority order

1. G01_P03_Агент_Анализа_Рынков
2. G01_P01_PocketOption
3. G01_P02_TradingView_Claude
4. G01_01_Group_Settings
5. G01_P04_Telegram_run_trade_paper_Alpaca
6. G01_P05 / G01_P06 / G01_P07 source projects
7. G01_P08_Copy_Trading
8. CODE / DOCS / DATA / HTML
9. ARCHIVES last, archive-only

## Rules for future AI agents

1. Read this file before touching G01.
2. Do not Git-init G01 root.
3. Do not push any folder marked API/key-like without private review.
4. Do not push any folder with large files using normal Git.
5. Create subproject-specific AI Context Capsule before cleanup or publishing.
6. Raw AI chats, jsonl, sqlite, mp3, video, installers, archives require LFS/archive decision.
7. Preserve trading project history and AI memory.
