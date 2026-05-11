# Repo Decision Map

Generated after read-only audit.

## Canonical main repo

Path:
J:\Setup_VcCode_Workspace\S10_GitHub\workspaces

GitHub:
https://github.com/Incomesbook/workspaces

Decision:
This is the main control / workspace / restore / index repository.

Purpose:
- workspace structure
- repo map
- restore instructions
- project indexes
- safe automation scripts
- references to external projects

Do not store:
- raw chat logs
- sqlite databases
- videos
- archives
- installers
- secrets
- API keys
- .env files
- huge diagnostics

## GitHub repositories

### Incomesbook/workspaces
Status:
- remote exists
- no commits on GitHub yet
- local repo has prepared safe commits

Decision:
- keep as canonical main repo
- first push only after final approval

### Incomesbook/Workspace
Status:
- has main branch
- only README.md, 11 bytes

Decision:
- legacy placeholder
- do not delete now
- later archive or rename only after final approval

### Incomesbook/canada-tax-optimizer
Status:
- live project repo
- has main branch
- local C: project has modified index.html and untracked project folders
- contains raw CODEX jsonl files over 100 MB in local chat history

Decision:
- keep as separate project repo
- do not merge into workspaces directly
- add safe project index/reference into workspaces
- raw chat jsonl must stay out of GitHub or use a separate backup strategy

### Incomesbook/signals
Status:
- empty repo, no commits yet

Decision:
- keep as reserved/empty for now
- do not delete now

## Local C drive findings

### Canada_Tax_Optimizer
Path:
C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\Canada_Tax_Optimizer

Git:
- branch main tracks origin/main
- remote: https://github.com/Incomesbook/canada-tax-optimizer.git
- changed file count: 7

Risk:
- local raw chat jsonl files exceed GitHub normal file limit

Decision:
- separate living project
- clean with .gitignore before any commit/push

### LiveControl
Path:
C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ\LiveControl

Git:
- local Git repo
- no remote
- changed file count: 3866
- last commits include complete chat log archive and backup

Risk:
- huge sqlite files around 13+ GB
- huge jsonl chat logs
- installers/exe
- archives/video/media
- dirty Git state

Decision:
- do not commit
- do not push
- do not merge into workspaces
- needs separate read-only audit and cleanup plan

### iNCOMEBOOK
Path:
C:\Users\IgorK\OneDrive\iNCOMEBOOK

Git:
- not a Git repo

Contents:
- INCOMEBOOK.xlsm
- Copy of INCOMEBOOK.xlsm

Decision:
- keep as legacy Excel source
- do not convert to Git repo now

## Current rule

Nothing is deleted.
Nothing is pushed.
Nothing is merged blindly.
Codex / Workspace automation must not be touched.
