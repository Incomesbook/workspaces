# G01 P01 Large / Private / Chat Manifest

## Project

G01_P01_PocketOption

## Local path

J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P01_PocketOption

## Purpose

This file is a GitHub-safe manifest only.

It documents:
- Chrome profile/cache/IndexedDB zones
- large files
- AI/chat roots
- ChatGPT/browser-extension related roots
- API/key/private-like folders
- runtime/log/data/results folders
- legacy imported PocketOption agent folders
- what must never be pushed blindly

It does not contain raw chat logs, credentials, API keys, tokens, passwords, cookies, sessions, browser local storage, IndexedDB data, or private file contents.

## Current decision

Do not initialize Git at G01_P01 root.
Do not push G01_P01 as a whole folder.
Do not run git add . inside G01_P01.
Do not copy raw project contents into Incomesbook/workspaces.

## Large files over 50 MB found by audit

| File / area | Size MB | Decision |
|---|---:|---|
| G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\PocketOption_VcCode\Agent_PocketOption_VcCode_V1\10_Артефакты\chrome_profile\Default\Cache\Cache_Data\data_3 | 253.51 | exclude/archive-only |
| G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\Imported_From_G01_P03_Market_Agent\Agent_PocketOption_VcCode_V1\10_Артефакты\chrome_profile\Default\Cache\Cache_Data\data_3 | 253.51 | exclude/archive-only |
| G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\PocketOption_VcCode\Agent_PocketOption_VcCode_V1\10_Артефакты\chrome_profile\Default\Cache\Cache_Data\data_5 | 232.01 | exclude/archive-only |
| G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\Imported_From_G01_P03_Market_Agent\Agent_PocketOption_VcCode_V1\10_Артефакты\chrome_profile\Default\Cache\Cache_Data\data_5 | 232.01 | exclude/archive-only |

## Protected Chrome / browser profile zones

Do not push blindly:

- G01_P01_01_Project\10_Артефакты\chrome_profile
- chrome_profile\Default\Cache
- chrome_profile\Default\IndexedDB
- chrome_profile\Default\Local Storage
- chrome_profile\Default\Session Storage
- chrome_profile\Default\Extension State
- chrome_profile\Default\Network
- chrome_profile\Default\WebStorage
- chrome_profile\Default\Sync Data
- chrome_profile\TrustTokenKeyCommitments
- chrome_profile\Default\Extensions

Decision:
- browser profile state is protected
- cache files are archive/exclude only
- IndexedDB/local storage/session storage may contain sensitive account/session/chat state
- never push whole browser profile to normal Git

## AI / chat / LLM roots

Protected roots:

- G01_P01_02_Project_Settings\G01_P01_02_05_AI_Memory
- G01_P01_02_Project_Settings\G01_P01_02_05_AI_Memory\G01_P01_02_05_01_Chat_Root
- G01_P01_02_Project_Settings\G01_P01_02_03_Sources\G01_P01_02_03_06_External_Memory
- G01_P01_02_Project_Settings\G01_P01_02_04_Knowledge\G01_P01_02_04_02_YouTube\Claude_Code_и_Разработка
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\PocketOption_VcCode\Agent_PocketOption_VcCode_V1
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\Imported_From_G01_P03_Market_Agent\Agent_PocketOption_VcCode_V1

Decision:
- do not delete
- do not move blindly
- do not push raw jsonl/db/log/browser state to normal Git
- preserve for future AI context and restore

## Browser / ChatGPT extension related roots

Review/protect:

- chrome_profile\Default\IndexedDB\https_chatgpt.com_0.indexeddb.leveldb
- chrome_profile\Default\Extensions\...\scripts\chatMenu
- chrome_profile\Default\Extensions\...\scripts\exportChat
- chrome_profile\Default\Extensions\...\scripts\GPTs
- chrome_profile\Default\Extensions\...\scripts\manageChats
- chrome_profile\Default\Extensions\...\scripts\moveChat
- chrome_profile\Default\Extensions\...\scripts\pinnedChats

Decision:
- extension source may be reviewed later
- browser profile state must not be pushed
- ChatGPT/IndexedDB data requires archive/encrypted backup decision
- never treat browser profile as clean source

## Private / API / access-like roots

Protected roots:

- G01_P01_02_Project_Settings\G01_P01_02_03_Sources\G01_P01_02_03_05_API_Keys_And_IDs
- chrome_profile\TrustTokenKeyCommitments
- chrome_profile\Default\Extensions\...\modules\token-approximator
- chrome_profile\Default\Extensions\...\modules\token-models
- chrome_profile\Default\Extensions\...\api

Decision:
- never push blindly
- never expose contents in public GitHub
- audit filenames before any future action
- commit only safe metadata/capsule/manifest files

## Runtime / logs / results / data roots

Review before any Git action:

- G01_P01_02_Project_Settings\G01_P01_02_06_Data
- G01_P01_02_Project_Settings\G01_P01_02_06_Data\G01_P01_02_06_01_JSON_And_JSONL
- G01_P01_02_Project_Settings\G01_P01_02_06_Data\G01_P01_02_06_02_Spreadsheets
- G01_P01_02_Project_Settings\G01_P01_02_06_Data\G01_P01_02_06_03_Runtime_Data
- G01_P01_02_Project_Settings\G01_P01_02_07_Results
- G01_P01_02_Project_Settings\G01_P01_02_07_01_HTML_Reports
- G01_P01_02_Project_Settings\G01_P01_02_07_02_Scan_Outputs
- G01_P01_02_Project_Settings\G01_P01_02_07_03_UI_Prototypes
- G01_P01_02_Project_Settings\G01_P01_02_08_Logs
- G01_P01_02_Project_Settings\G01_P01_02_08_Logs\File_Router
- G01_P01_02_Project_Settings\G01_P01_02_08_Logs\G01_P01_02_08_01_Imported_Logs
- G01_P01_02_Project_Settings\G01_P01_02_08_Logs\YouTube

Decision:
- likely manifest-only or archive layer
- not normal Git until reviewed
- generated runtime files should not mix with clean source

## Legacy roots

Preserve, but do not push blindly:

- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\PocketOption_VcCode
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\Imported_From_G01_P03_Market_Agent
- Agent_PocketOption_VcCode_V1 folders

Decision:
- keep history
- do not delete
- audit before extracting clean source
- exclude chrome profiles, cache, pycache, logs, runtime artifacts

## Possible future clean-source candidates

Review later:

- selected automation scripts
- selected project skills
- selected rules/instructions
- selected code from Agent_PocketOption_VcCode_V1 after excluding runtime/browser/cache/private files
- selected docs that do not contain secrets, account state, or raw browser/chat data

## Not yet decided

- whether G01_P01 should get a CleanSource extraction
- whether any selected files should get a separate GitHub repo
- whether raw AI/chat/browser state should use encrypted backup
- whether any large assets should use Git LFS
- whether Chrome/IndexedDB artifacts should be archive-only

## Next safe action

Create a read-only clean-source candidate audit for G01_P01.

Do not copy yet.
Do not move yet.
Do not Git-init yet.
