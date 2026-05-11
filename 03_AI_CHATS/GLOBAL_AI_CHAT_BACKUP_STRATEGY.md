# Global AI Chat Backup Strategy

## Purpose

Create a safe backup strategy for Igor's AI chats, AI memory, Claude/Codex/Copilot/ChatGPT-related files, VS Code workspace history, and project restore context.

## Current decision

This phase is strategy/index only.

It does not:
- copy raw chats
- copy browser profiles
- copy cookies/session/local storage/IndexedDB
- expose secrets
- enable Git LFS
- create encrypted archives
- enable scheduled sync

## Latest metadata CSV

J:\_AI_CHATS_ОБЩИЕ\_AUDIT\GLOBAL_AI_CHAT_ROOTS_INDEX_20260511_073726.csv

## Summary

- Existing roots scanned: 7
- Metadata rows indexed: 404942
- Represented MB: 481031.08
- Large >50MB rows: 1131
- Huge >500MB rows: 155
- Secret-like rows redacted: 60825
- Browser-state rows: 90204

## Why not push raw chats directly

GitHub warns on files larger than 50 MiB, and large object/repository limits make huge raw chat dumps unsuitable for normal Git. Git LFS can be used later, but only after explicit tracking rules and a separate storage decision.

Browser state and private/session/API-like files are not suitable for normal GitHub backup.

## Strategy

1. Normal Git:
   - capsules
   - manifests
   - restore plans
   - small redacted AI context summaries
   - safe scripts
   - small indexes without raw secrets

2. Git LFS candidate:
   - selected large but non-private files only
   - only after review
   - only after .gitattributes rules are approved

3. Encrypted private archive:
   - raw AI chats
   - raw jsonl
   - raw chat exports
   - selected IndexedDB/browser-state only if needed for restore
   - never public, never normal Git

4. Local archive only:
   - caches
   - browser cache
   - runtime output
   - temporary files
   - generated logs
   - installers/media

5. Manifest only:
   - secret-like locations
   - API/private/session/cookie/browser-state references
   - anything not safe to copy
