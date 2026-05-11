# AI Chats Export Import Manifest

## Purpose

This file tracks what must be backed up so Igor can continue projects and AI conversations later, including from another computer.

## Current truth

Native AI chat sessions are not the same as GitHub backup.

We need three layers:
1. Native/local session storage
2. Export/archive storage
3. AI Context Capsule per project

## Confirmed local chat/storage sources from audit

### Claude local

Path:
C:\Users\IgorK\.claude

Status:
- Exists
- Contains projects, sessions, history, jsonl files, configs
- Contains credentials file, which must never be pushed

Decision:
- Do not push the raw folder blindly
- Create a safe index first
- Exclude credentials and secrets
- Later decide: Git LFS / encrypted archive / local backup layer

### Claude desktop config/logs

Paths:
C:\Users\IgorK\AppData\Roaming\Claude
C:\Users\IgorK\AppData\Local\Claude

Status:
- Exists
- Mostly config/log data

Decision:
- Backup configs only after secret review
- Do not push raw config blindly

### Shared AI chats

Paths:
J:\_AI_CHATS_ОБЩИЕ
J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats
J:\ClaudeData
J:\ClaudeHub

Decision:
- Protected
- Do not delete
- Do not move blindly
- Do not push raw huge archives into normal Git

## Web/Desktop export sources still required

### ChatGPT web / desktop

Required action later:
- Export from ChatGPT Settings > Data Controls > Export Data
- Store export in protected archive location
- Add manifest entry after export exists

### Claude web / desktop

Required action later:
- Export from Claude Settings > Privacy
- Store export in protected archive location
- Add manifest entry after export exists

### VS Code Copilot Chat

Required action later:
- Export important chat sessions from VS Code Chat view using Chat export command
- Store exported JSON in protected archive location
- Add manifest entry after export exists

## Project context capsule status from audit

Missing capsule files in important projects:
- PROJECT_STATE.md
- NEXT_ACTIONS.md
- AI_MEMORY.md
- CHATS_INDEX.md
- DECISIONS.md
- RESTORE_NOTES.md

Priority projects:
1. J:\Setup_VcCode_Workspace\S20_Projects\LiveControl_CleanSource
2. J:\ПРОЕКТЫ\G01_All_About_Trading
3. J:\ПРОЕКТЫ\G02_Life_Control
4. C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\Canada_Tax_Optimizer
5. C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\LiveControl
6. C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\tradingview-claude
7. C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\youtube_analysis

## Rule

No raw chat GitHub push yet.
No credentials GitHub push ever.
No delete.
No move.
No blind sync.

Next safe step:
Create safe AI chat index script that records paths, sizes, dates, and project mapping, but does not copy raw chat content.
