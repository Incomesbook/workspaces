# AI Chat Gitignore And Exclude Policy

## Normal Git allowed

- capsules
- manifests
- restore notes
- safe summaries
- safe indexes
- safe scripts

## Never push blindly

- *.jsonl
- *.sqlite
- *.db
- *.log
- browser cache
- Chrome profiles
- IndexedDB
- Local Storage
- Session Storage
- cookies
- auth/session data
- API/private/key folders
- .env
- raw chat exports
- huge diagnostics
- installers
- media dumps

## Recommended ignore patterns for future raw-chat repos

*.jsonl
*.sqlite
*.db
*.log
*.ldb
*.lock
*.env
*.zip
*.7z
*.rar
*.mp4
*.mp3
*.wav
*.pdf
**/Cache/**
**/Code Cache/**
**/GPUCache/**
**/IndexedDB/**
**/Local Storage/**
**/Session Storage/**
**/Extension State/**
**/Network/**
**/WebStorage/**
**/*token*
**/*secret*
**/*password*
**/*credential*
**/*api_key*
**/*private_key*
