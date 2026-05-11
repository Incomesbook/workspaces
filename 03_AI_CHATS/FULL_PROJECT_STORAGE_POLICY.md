# Full Project Storage Policy

## Core rule

No project file is considered lost just because it is not suitable for normal Git.

Filtering does not mean deleting.
Filtering means routing each file to the correct storage layer.

## Storage layers

1. NORMAL_GIT
   - source code
   - small configs without secrets
   - capsules
   - manifests
   - restore notes
   - safe scripts

2. GIT_LFS
   - large non-private project assets
   - only after explicit approval
   - only after .gitattributes rules are approved

3. ENCRYPTED_ARCHIVE
   - raw AI chats
   - Claude/Codex/Copilot/ChatGPT exports
   - private AI memory
   - sensitive restore data
   - browser/IndexedDB/session state only if restore-critical

4. LOCAL_ARCHIVE_ONLY
   - cache
   - runtime output
   - installers
   - generated diagnostics
   - files useful for history but not required for clean project operation

5. RECREATE_FROM_SCRIPT
   - dependencies
   - node_modules
   - .venv
   - temporary generated outputs
   - cache that can be rebuilt

6. MANIFEST_ONLY
   - references to sensitive/private/unknown files
   - files requiring manual review before storage decision

## Latest detailed manifest

J:\_AI_CHATS_ОБЩИЕ\_AUDIT\FULL_PROJECT_STORAGE_RESTORE_MANIFEST_20260511_080141.csv

## Summary

- Total metadata rows: 404942
- Total MB represented: 481031.08
- LFS candidates: 253
- Encrypted/archive candidates: 272927
- Local-only candidates: 930
- Private candidates: 60825
- AI context candidates: 256499

## Decision

This phase creates the full routing map.
It does not copy raw files.
It does not enable Git LFS.
It does not create encrypted archives.
