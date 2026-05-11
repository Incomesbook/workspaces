# Encrypted Archive Security Policy

## Critical rule

Never paste real archive passwords into ChatGPT.
Never save archive passwords in GitHub.
Never commit passwords in scripts, .env files, markdown files, CSV files, or restore manifests.

## Real archive password handling

For real archive execution:
- the script must ask locally with Read-Host -AsSecureString
- the password must not be written to disk
- the password must not be printed to console
- the password must not be committed to GitHub
- the password must be stored only by Igor in a private/offline password manager

## Command-line limitation

7-Zip command-line needs a password passed to the process.
That can be visible locally to process inspection tools while the command runs.

For the most sensitive archive layer, consider later:
- VeraCrypt container
- Cryptomator vault
- rclone crypt remote
- offline encrypted drive backup

## Current rule

Do not run full archive yet.

Allowed next:
- missing-source dry-run
- tiny real shard archive test with local password prompt
- verify extract and hash on tiny sample

Not allowed yet:
- full raw archive
- scheduled sync
- deleting originals
