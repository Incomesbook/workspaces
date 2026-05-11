# AI Chat Auto Local Raw Mirror Policy

## Goal

New AI chats and new AI tool data should be copied automatically into:

J:\_AI_CHATS_ОБЩИЕ\_SOURCES

## Rules

Allowed:
- frequent local copy
- logon local copy
- dynamic discovery of AI-related folders
- manifest/status/control GitHub commits

Blocked:
- deletion
- move
- robocopy /MIR
- raw GitHub push
- Git LFS
- ENV/PATH redirect
- archive/password workflow

## Frequency

Every 30 minutes plus Windows logon.