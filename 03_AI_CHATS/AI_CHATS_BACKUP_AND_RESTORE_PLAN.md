# AI Chats Backup and Restore Plan

## Main goal

Preserve years of AI conversations, project context, decisions, code history, and working state so Igor can continue development from where he stopped.

## Important truth

A native live chat session inside VS Code, Claude Desktop, ChatGPT web, Codex, Copilot, Gemini, Cursor, or another AI tool is not automatically the same as a GitHub backup.

The backup system must have three layers:

1. Native app/session layer
   - Keep local app/session storage where possible.
   - Do not delete VS Code/Codex/Claude/Copilot session folders.

2. Raw export/archive layer
   - Store exported chat files, json/jsonl/html/md/text when available.
   - Large raw exports must not be blindly committed to normal Git.
   - Use Git LFS, encrypted archive, or local/archive backup strategy for big files.

3. AI Context Capsule layer
   - Each important project must have small markdown files any AI can read:
     PROJECT_STATE.md
     NEXT_ACTIONS.md
     AI_MEMORY.md
     CHATS_INDEX.md
     DECISIONS.md
     RESTORE_NOTES.md

## Protected chat roots

- J:\_AI_CHATS_ОБЩИЕ
- J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats
- J:\ClaudeData
- J:\ClaudeHub

## AI systems to track

- ChatGPT web / desktop exports
- Claude web / desktop / Claude Code / Claude Cowork
- Codex
- Copilot Chat / Copilot sessions in VS Code
- Gemini
- Cursor
- Blackbox
- OpenRouter / OmniRoute routed sessions
- Any project-specific local chat folders

## Rule

Do not delete chats.
Do not move chats blindly.
Do not push huge raw chats blindly.
Do not assume web chats are backed up unless export/manifest proves it.
Do not assume local VS Code sessions are restorable unless restore test proves it.

## What must be proven later

1. Where each AI stores local history.
2. Which histories can be exported.
3. Which histories are small enough for normal Git.
4. Which histories need Git LFS or archive backup.
5. Which project has an AI Context Capsule.
6. Whether a fresh AI session can understand the project by reading the capsule.
7. Whether a restored VS Code workspace can see project files and chat indexes.
