# Large Files Policy

GitHub is not the storage place for every large local file.

Never push these to normal Git:
- raw chat .jsonl
- sqlite databases
- videos
- installers
- archives
- huge diagnostics
- local caches
- secrets
- API keys
- .env files

Observed risky examples:
- LiveControl sqlite files around 13+ GB
- LiveControl sqlite files around 2+ GB
- LiveControl raw chat jsonl/txt files around 1+ GB
- Canada_Tax_Optimizer raw CODEX jsonl files around 197 MB and 155 MB

Policy:
- code and small docs go to Git
- big local runtime/history/archive files stay in local archive
- GitHub stores a manifest describing them
- Git LFS may be considered only for selected assets that are genuinely part of a project
- Git LFS is not the default answer for diagnostic databases, raw AI chat dumps, installers, videos, and duplicated archives

Restore idea:
GitHub restores:
- structure
- source code
- scripts
- manifests
- workspace files
- instructions

Local/archive storage restores:
- huge raw histories
- sqlite diagnostics
- videos
- installers
- full media/archive dumps
