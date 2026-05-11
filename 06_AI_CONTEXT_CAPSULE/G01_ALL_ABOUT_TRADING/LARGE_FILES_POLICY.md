# LARGE_FILES_POLICY

## Audit finding

G01 contains files over 50 MB.

Examples:
- large trading PDF files
- platform installers
- Chrome cache data
- TradingView / broker installers
- mp3 learning files
- Claude jsonl export over 50 MB

## Rule

Do not push these files to normal Git.

Recommended future handling:
- large PDFs: archive/LFS decision
- installers: archive-only, usually not Git
- Chrome cache/runtime: exclude
- mp3/video/media: archive/LFS decision
- raw jsonl chat exports: archive/LFS/encrypted backup decision
- API/key/private folders: never push blindly
