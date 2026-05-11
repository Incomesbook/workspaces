# Storage Layer Decision Matrix

## Matrix

| Storage layer | Use for | Do not use for | Current status |
|---|---|---|---|
| NORMAL_GIT | code, rules, capsules, manifests, small safe configs | raw chats, secrets, browser state, huge files | active |
| GIT_LFS | approved large non-private assets | secrets, cookies, sessions, raw private chats without review | not enabled yet |
| ENCRYPTED_ARCHIVE | raw AI chats, private memory, sensitive restore data | cache-trash, public source code | not created yet |
| LOCAL_ARCHIVE_ONLY | cache, installers, runtime, diagnostics, historical dumps | files required for clean project clone | not created yet |
| RECREATE_FROM_SCRIPT | dependencies/cache/build output | unique project memory | not implemented yet |
| MANIFEST_ONLY | sensitive references, unknown review items | files required for immediate run | active |

## Current counts by storage


StorageLayer                                   Files        MB
------------                                   -----        --
DO_NOT_PUSH_PRIVATE__ENCRYPTED_ARCHIVE_REVIEW  60825 275022.86
LOCAL_OR_ENCRYPTED_ARCHIVE__SPLIT_IF_NEEDED       30  74099.94
ENCRYPTED_ARCHIVE_OR_LOCAL_ONLY                86435  63421.18
GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE           253   43596.6
MANIFEST_OR_REDACTED_SUMMARY                  131115  15612.15
LOCAL_ARCHIVE_ONLY                               900   5475.37
ENCRYPTED_ARCHIVE_RECOMMENDED                 125384   3802.99




## Next decision

Build archive plan in this order:
1. encrypted archive candidates
2. Git LFS candidate review
3. local archive-only review
4. restore test
