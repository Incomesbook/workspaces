# Archive Dry-Run Plan

## Purpose

Move from “filtered out” to “routed to storage layer”.

This is a dry-run plan only.

## Source manifest

J:\_AI_CHATS_ОБЩИЕ\_AUDIT\FULL_PROJECT_STORAGE_RESTORE_MANIFEST_20260511_080141.csv

## Generated dry-run CSVs

- Encrypted archive candidates:
  J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_20260511_085704.csv

- Git LFS candidates:
  J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ARCHIVE_DRYRUN_LFS_CANDIDATES_20260511_085704.csv

- Local archive-only candidates:
  J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ARCHIVE_DRYRUN_LOCAL_ONLY_CANDIDATES_20260511_085704.csv

- Private review candidates:
  J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ARCHIVE_DRYRUN_PRIVATE_REVIEW_20260511_085704.csv

- AI context candidates:
  J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ARCHIVE_DRYRUN_AI_CONTEXT_CANDIDATES_20260511_085704.csv

## Future target roots

- Encrypted archive root:
  J:\Setup_VcCode_Workspace\S30_Large_Local_Archive\ENCRYPTED_AI_CHAT_ARCHIVE

- Git LFS review root:
  J:\Setup_VcCode_Workspace\S30_Large_Local_Archive\GIT_LFS_REVIEW

- Local archive-only root:
  J:\Setup_VcCode_Workspace\S30_Large_Local_Archive\LOCAL_ONLY_ARCHIVE

- Restore manifests:
  J:\Setup_VcCode_Workspace\S40_Restore_Manifests

## Counts

- Total rows: 404942
- Total MB represented: 481031.08
- Encrypted archive candidates: 404042 / 475555.72 MB
- Git LFS candidates: 253 / 43596.6 MB
- Local-only candidates: 930 / 79575.31 MB
- Private review candidates: 60825 / 275022.86 MB
- AI context candidates: 256499 / 19415.14 MB

## Tool check

- 7z available: False
- git lfs available: True

## Decision

No files were copied.
No archive was created.
No Git LFS tracking was enabled.
No sync was enabled.
