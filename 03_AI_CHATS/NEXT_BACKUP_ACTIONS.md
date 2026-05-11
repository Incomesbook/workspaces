# Next Backup Actions

## Current state

Archive dry-run plan completed.

## Done

- Full storage manifest exists.
- Storage policy exists.
- Archive dry-run CSVs exist.
- Encrypted archive candidate plan exists.
- Git LFS review dry-run plan exists.
- Local archive dry-run plan exists.
- Restore test checklist exists.

## Next recommended order

### 1. Choose encrypted archive method

Recommended options to decide manually:
- 7z AES-256 archive if 7z is installed
- VeraCrypt container
- Cryptomator vault
- rclone crypt remote
- private offline drive backup

Do not create archive until destination and password/key policy are clear.

### 2. Create encrypted archive dry-run verification

Before real archive:
- count files
- count MB
- check missing paths
- split by root
- exclude secret-like filenames from normal logs
- write restore instructions

### 3. Review Git LFS candidates

Before enabling LFS:
- verify non-private
- verify required for project
- verify GitHub quota
- test clone

### 4. Weekly/biweekly sync dry-run

Do not enable scheduled sync yet.
First create dry-run task that only reports what would change.

### 5. Restore test

Only after archive exists.
