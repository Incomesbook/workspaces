# AI Chat Weekly Safe Sync Gate

Mode: WEEKLY SYNC NOT ENABLED.

## What is allowed next

A weekly job may be prepared only for safe metadata/manifests/control docs after explicit approval.

## What is blocked

- raw chat sync to GitHub
- Git LFS enable
- encrypted archive execution
- password prompt
- schedule creation
- ENV/PATH edits
- deletion
- original file movement

## Recommended final architecture

1. Local common root keeps actual raw histories where approved.
2. GitHub workspaces repo stores manifests, restore maps, policies, status docs.
3. Weekly automation starts with manifest-only commits.
4. Raw GitHub sync remains blocked unless separately approved.