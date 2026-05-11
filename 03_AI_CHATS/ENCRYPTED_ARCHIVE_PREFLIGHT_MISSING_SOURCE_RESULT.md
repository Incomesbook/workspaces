# Encrypted Archive Preflight Missing Source Result

## Source split plan

J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ENCRYPTED_ARCHIVE_SPLIT_PLAN_20260511_092122.csv

## Output CSV

J:\_AI_CHATS_ОБЩИЕ\_AUDIT\ENCRYPTED_ARCHIVE_PREFLIGHT_MISSING_SOURCE_20260511_093547.csv

## Result

- Total rows: 404042
- Checkable rows: 343217
- Redacted/uncheckable rows: 60825
- Existing checkable rows: 318907
- Missing checkable rows: 24310
- Uncheckable rows: 60825

## Meaning

Checkable rows can be reconstructed from:
Root + RelativeFolder + FileName.

Uncheckable rows are usually redacted/private/secret-like references.
They require separate private handling and should not be blindly archived from public/normal manifests.

## Decision

No full archive yet.
Missing-source dry-run completed.
