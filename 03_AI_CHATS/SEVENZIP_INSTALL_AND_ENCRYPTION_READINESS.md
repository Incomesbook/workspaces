# SevenZip Install And Encryption Readiness

## Why 7-Zip

7-Zip .7z archives support AES-256 encryption and can encrypt archive headers/file names.

## Current status

- 7z found before prompt: False
- 7z found after prompt: False
- 7z final path: NOT FOUND
- Install attempted: True
- Install result: INSTALL_ATTEMPTED_BUT_7Z_NOT_IN_PATH
- winget found: True

## Password rule

Never paste archive passwords into ChatGPT.
Never save archive passwords inside GitHub.
Future archive script should ask for password locally or use a local-only protected key file.

## Next

If 7z is available:
- create tiny encrypted test archive
- verify archive can list and extract
- then create split archive dry-run

If 7z is not available:
- install 7-Zip first
- re-run readiness check
