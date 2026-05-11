# Master Restore Plan

## Goal

On another computer, restore the J-based workspace structure with:
- master VS Code workspace
- project indexes
- chat indexes
- automation maps
- restore instructions
- clean project locations

## Main restore source

GitHub:
https://github.com/Incomesbook/workspaces

Local target:
J:\Setup_VcCode_Workspace

## Restore principle

The GitHub workspaces repo restores the structure and control layer.
Large archives, raw chats, sqlite diagnostics, videos, installers, and old dirty repos are restored from local/archive/backup layers using manifests, not blindly stored in one huge Git repo.

## Current protected chat roots

- J:\_AI_CHATS_ОБЩИЕ
- J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats
- J:\ClaudeData
- J:\ClaudeHub

## Current project roots

- J:\Setup_VcCode_Workspace
- J:\Setup_VcCode_Workspace\S20_Projects
- J:\ПРОЕКТЫ
- C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ
- C:\Users\IgorK\OneDrive\iNCOMEBOOK

## Next real work

1. Finish master indexes.
2. Build full restore checklist.
3. Build weekly/biweekly sync plan.
4. Only then decide project-by-project what is copied, linked, or turned into separate repo/submodule.
