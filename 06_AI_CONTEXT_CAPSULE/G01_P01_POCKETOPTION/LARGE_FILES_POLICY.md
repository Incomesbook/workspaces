# LARGE_FILES_POLICY

## Large files found by audit

- Legacy PocketOption chrome profile cache data_3 | 253.51 MB
- Imported_From_G01_P03_Market_Agent chrome profile cache data_3 | 253.51 MB
- Legacy PocketOption chrome profile cache data_5 | 232.01 MB
- Imported_From_G01_P03_Market_Agent chrome profile cache data_5 | 232.01 MB

## Decision

Do not push these files to normal Git.

Future handling:
- Chrome cache/runtime: exclude/archive-only
- browser profile: protected, never push blindly
- IndexedDB/chat state: protected archive/encrypted backup decision
- extension scripts: source review only, not whole profile push
- raw jsonl/db/log/runtime files: archive/LFS/private decision
