# Master Structure and Memory Lock

## Purpose

This file is the persistent memory anchor for Igor's J-based VS Code / GitHub / AI workspace.

The goal is not only to store code.
The goal is to preserve:
- projects
- AI chats
- AI context
- restore instructions
- automation rules
- workspace structure
- development continuity across AI agents and computers

## Current confirmed Git state

Main repo:
https://github.com/Incomesbook/workspaces

Latest confirmed commit:
8af74bb Refine AI chats safe index filter

Status:
main is synced with origin/main.

## Main local structure from screenshots

J:\Setup_VcCode_Workspace

Top-level folders:
- S01_Shared_Start_Here
- S02_Shared_VSCode
- S03_Shared_Access
- S04_Shared_Connections
- S05_Shared_Registry
- S06_Shared_Automation
- S07_Shared_Backup_And_Recovery
- S08_Shared_Global_AI_Chats
- S09_Shared_Private
- S10_GitHub
- S20_Projects
- VcCode

## Important J:\Setup_VcCode_Workspace layers

### S01_Shared_Start_Here
Purpose:
- architecture maps
- specs and standards
- rules/templates

### S02_Shared_VSCode
Purpose:
- shared VS Code user settings
- portable VS Code
- project workspaces
- runtime
- backups
- recovery
- launch/start scripts

### S03_Shared_Access
Purpose:
- API keys and IDs
- access policies
- private access files

Rule:
Do not push blindly.

### S04_Shared_Connections
Purpose:
- connectors
- MCP connections
- program connections
- cloud notebooks
- web services

### S05_Shared_Registry
Purpose:
- project registry
- global AI memory
- error ledger
- runtime data and indexes
- model behavior notes
- master maps and indexes

### S06_Shared_Automation
Purpose:
- project bootstrap
- project chat automation
- YouTube ingest
- AI chat index/export
- migration/reconciliation
- templates
- reports
- rollback
- admin tools
- knowledge export
- project file router
- platform bridges
- ChatWizard unified index

Protected:
- ProjectChatAutomation.ps1
- Watch-JWorkspaceProjectBootstrap.ps1
- all active Codex/Claude/VS Code automation

### S07_Shared_Backup_And_Recovery
Purpose:
- archives
- runtime archives
- recovery index
- restore tools
- backup audits
- locked/special roots
- project root archives
- GitHub backup
- VS Code runtime link fixes
- disabled VS Code extensions snapshots

### S08_Shared_Global_AI_Chats
Purpose:
- GPT
- Claude
- Gemini
- Codex
- Copilot
- Cursor
- other AI chats
- shared project AI chats
- auto import history
- AI chat tools
- AI chat reports and restore

Rule:
Protected. Do not delete. Do not move blindly. Do not push raw huge chats directly to normal Git.

### S09_Shared_Private
Purpose:
- disabled/quarantined items
- private local state
- private admin files

Rule:
Never push blindly.

### S10_GitHub
Purpose:
- GitHub control repos
- main workspaces repo
- GitHub index/restore layer

### S20_Projects
Purpose:
- clean project candidates
- source-clean project copies
- projects prepared for controlled GitHub strategy

Current known project:
- LiveControl_CleanSource

## J:\ПРОЕКТЫ structure from screenshots

Important group:
J:\ПРОЕКТЫ\G01_All_About_Trading

Known substructure:
- G01_01_Group_Settings
- G01_01_01_Group_Profile
- G01_01_02_Shared_Connections
- G01_01_02_01_API_Keys_And_IDs
- G01_01_02_02_MCP
- G01_01_02_03_Programs
- G01_01_02_04_Cloud_Notebooks
- G01_01_02_05_Web_Services
- G01_01_03_Shared_Knowledge
- G01_01_03_01_Analysis
- G01_01_03_02_Learning
- G01_01_03_03_Trading
- G01_01_04_Shared_AI_Memory
- G01_01_04_01_Group_Chat_Root
- G01_01_05_Shared_Engines_And_Automation
- G01_01_06_Shared_Tools
- G01_01_07_Shared_Logs
- G01_01_08_Group_Tech
- G01_01_08_01_Project_Root
- vscode
- G01_01_09_Group_Navigation
- G01_01_10_Group_Legacy
- ClaudeToTradingView
- G01_P01_PocketOption
- G01_P02_TradingView_Claude
- G01_P03_Агент_Анализа_Рынков
- G01_P04_Telegram_run_trade_paper_Alpaca
- G01_P05_AIWedSources_Technical_Analysis
- G01_P06_SourceIFO_SotialMedia
- G01_P07_SourceIFO_Youtube
- G01_P08_Copy_Trading

## AI chat backup current confirmed summary

From AI_CHATS_SAFE_INDEX_SUMMARY.md:

- likely chat/runtime metadata rows: 125936
- total MB represented: 169910.98
- files needing LFS/archive by size: 468
- strict secret-like filenames excluded: 382
- noise files ignored: 381352

By system:
- AI_COMMON: 4306 files / 10029.32 MB / 26 need LFS/archive
- S08_GLOBAL_AI_CHATS: 94271 files / 118240.64 MB / 329 need LFS/archive
- CLAUDE_USERPROFILE: 367 files / 98.63 MB / 0 need LFS/archive
- CLAUDE_ROAMING: 1 file / 0 MB
- CLAUDE_LOCAL: 1 file / 0 MB
- VSCODE_SHARED: 26990 files / 41542.39 MB / 113 need LFS/archive

## Permanent operating rules

1. Do not delete anything blindly.
2. Do not move projects blindly.
3. Do not push raw huge chats into normal Git.
4. Do not push credentials, tokens, passwords, API keys, .env, or private files.
5. Do not break Codex / Claude / VS Code automation.
6. Keep Incomesbook/workspaces as the main control repo.
7. Keep projects separate unless a project-specific plan approves otherwise.
8. Use manifests, indexes, restore plans, and AI Context Capsules.
9. Any future AI must read this file first before changing workspace structure.
10. The main goal is continuity: continue work from the last state with project context and AI history.

## Next priority

Create AI Context Capsules for:
1. Incomesbook/workspaces
2. J:\Setup_VcCode_Workspace
3. J:\ПРОЕКТЫ\G01_All_About_Trading
4. J:\Setup_VcCode_Workspace\S20_Projects\LiveControl_CleanSource
5. Canada_Tax_Optimizer
6. LiveControl legacy source

## Not finished yet

- Full web/Desktop ChatGPT export is not confirmed.
- Full Claude web/Desktop export is not confirmed.
- Full Copilot chat export is not confirmed.
- Weekly/biweekly sync is not enabled yet.
- Restore test on a clean machine is not done yet.
- Project-level AI Context Capsules are not done yet.
