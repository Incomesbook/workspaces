# G01 P03 Large / Private / Chat Manifest

## Project

G01_P03_Агент_Анализа_Рынков

## Local path

J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P03_Агент_Анализа_Рынков

## Purpose

This file is a GitHub-safe manifest only.

It documents:
- large files
- AI/chat roots
- Claude/local agent exports
- private/API/key-like folders
- runtime/log folders
- installer/binary folders
- what must never be pushed blindly

It does not contain raw chat logs, credentials, API keys, tokens, passwords, or private file contents.

## Current decision

Do not initialize Git at G01_P03 root.
Do not push G01_P03 as a whole folder.
Do not run git add . inside G01_P03.
Do not copy raw project contents into Incomesbook/workspaces.

## Large files over 50 MB found by audit

| File / area | Size MB | Decision |
|---|---:|---|
| G01_P03_02_04_Knowledge\G01_P03_02_04_06_Обучение\Telegram_ОБУЧЕНИЕ_ТРЕЙДИГУ\Кауфман - Системы и методы.pdf | 413.85 | archive/LFS review |
| G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS\ntws-latest-standalone-macosx-x64.dmg | 292.12 | archive-only |
| G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS\TradingView.msix | 129.13 | archive-only |
| G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS\MT2Trading.zip | 112.66 | archive-only |
| G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS\QuestradeGlobal-11.48.0-x64_en-US.msi | 108.46 | archive-only |
| G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS\NinjaTrader.Install.msi | 78.40 | archive-only |
| G01_P03_02_04_Knowledge\G01_P03_02_04_06_Обучение\Telegram_ОБУЧЕНИЕ_ТРЕЙДИГУ\016_piper.mp3 | 73.24 | archive/LFS review |
| G01_P03_02_04_Knowledge\G01_P03_02_04_06_Обучение\Telegram_ОБУЧЕНИЕ_ТРЕЙДИГУ\006_piper.mp3 | 59.51 | archive/LFS review |
| G01_P03_02_05_AI_Memory\G01_P03_02_05_01_Imported_Claude_Exports\CLAUDE_LOCAL_AGENT\local_2aff6312-6fb4-4c6c-baf1-e23927b765c6__audit.jsonl | 53.21 | protected chat archive |
| G01_P03_02_04_Knowledge\G01_P03_02_04_06_Обучение\Telegram_ОБУЧЕНИЕ_ТРЕЙДИГУ\010_piper.mp3 | 52.19 | archive/LFS review |
| G01_P03_02_04_Knowledge\G01_P03_02_04_06_Обучение\Telegram_ОБУЧЕНИЕ_ТРЕЙДИГУ\007_piper.mp3 | 52.19 | archive/LFS review |

## AI / chat / LLM roots

Protected roots:

- G01_P03_01_Project\_AI_INBOX\CLAUDE_LOCAL_AGENT
- G01_P03_02_Project_Settings\G01_P03_02_05_AI_Memory
- G01_P03_02_Project_Settings\G01_P03_02_05_AI_Memory\G01_P03_02_05_01_Chat_Root
- G01_P03_02_Project_Settings\G01_P03_02_05_AI_Memory\G01_P03_02_05_01_Imported_Claude_Exports
- G01_P03_02_Project_Settings\G01_P03_02_08_Logs\Claude_Local_Agent_Bridge

Decision:
- do not delete
- do not move blindly
- do not push raw jsonl to normal Git
- preserve for future AI context and restore

## Private / API / access-like roots

Protected roots:

- G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_And_Service_References
- G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_Keys_And_IDs

Decision:
- never push blindly
- never expose contents in public GitHub
- audit filenames before any future action
- commit only safe metadata/capsule/manifest files

## Runtime / logs / results roots

Review before any Git action:

- G01_P03_02_Project_Settings\G01_P03_02_06_Data
- G01_P03_02_Project_Settings\G01_P03_02_07_Results
- G01_P03_02_Project_Settings\G01_P03_02_08_Logs
- G01_P03_02_Project_Settings\G01_P03_02_11_Legacy

Decision:
- likely manifest-only or archive layer
- not normal Git until reviewed
- scan outputs and runtime files may be regenerated, so do not mix them with clean source

## Installer / binary roots

Archive-only by default:

- G01_P03_02_Project_Settings\G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries
- G01_P03_02_Project_Settings\G01_P03_02_10_Tech\G01_P03_02_10_02_Installers_And_Binaries\PLATFORM_INSTALLERS

Decision:
- do not push installers to normal Git
- keep local/archive backup
- use restore manifest if needed

## Possible future clean-source candidates

Review later:

- G01_P03_01_Project
- G01_P03_02_Project_Settings\G01_P03_02_09_Tools\G01_P03_02_09_01_PROJECT_SKILLS
- G01_P03_02_Project_Settings\G01_P03_02_09_Tools\G01_P03_02_09_04_Automation_Scripts
- selected docs/notes that do not contain secrets or large files

## Not yet decided

- whether G01_P03 should get its own separate GitHub repo
- whether any large files should use Git LFS
- whether raw AI chat archives should use encrypted backup
- whether installers should remain local-only or archive-only
- whether a clean-source extraction should be created under S20_Projects

## Next safe action

Create a read-only clean-source candidate audit for G01_P03.

Do not copy yet.
Do not move yet.
Do not Git-init yet.
