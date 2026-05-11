# AI Context Capsule Standard

## Purpose

Every important project should contain a small, AI-readable context package so any AI agent can continue work even if the original live chat session is unavailable.

## Required files per project

### PROJECT_STATE.md
Current project status, architecture, key files, what works, what is broken.

### NEXT_ACTIONS.md
Exact next steps, in order, with commands if needed.

### AI_MEMORY.md
Important long-term facts, preferences, decisions, mistakes to avoid.

### CHATS_INDEX.md
Links/paths to relevant AI chats, exports, logs, and summaries.

### DECISIONS.md
Major project decisions and why they were made.

### RESTORE_NOTES.md
How to restore the project on another computer.

## Rule

The capsule must be small enough for normal Git.
Raw chat logs can be referenced from the capsule, but huge raw logs should stay in archive/LFS/backup layer.

## Minimum success test

Open a new AI session.
Point it to the project folder and AI Context Capsule.
The AI must understand:
- what the project is
- what was done
- what should not be touched
- what to do next
