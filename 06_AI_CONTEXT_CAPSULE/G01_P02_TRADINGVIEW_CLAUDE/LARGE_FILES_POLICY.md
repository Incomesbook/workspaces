# LARGE_FILES_POLICY

## Large files found by audit

- No files over 50 MB found in audit.

## Decision

Do not push large files to normal Git.

Future handling:
- normal Git only for small source/capsule/manifest files
- Git LFS only after explicit strategy
- archive-only for cache/runtime/browser state
- encrypted/private backup decision for raw AI/chat/browser/session material
