# PRIVATE_AND_ACCESS_POLICY

## API/key/private/access-like roots from audit

Protected roots and hits include:

- G01_P01_02_Project_Settings\G01_P01_02_03_Sources\G01_P01_02_03_05_API_Keys_And_IDs
- chrome_profile\TrustTokenKeyCommitments
- chrome_profile\Default\Extensions\...\modules\token-approximator
- chrome_profile\Default\Extensions\...\modules\token-models
- chrome_profile\Default\Extensions\...\api

## Rule

Do not push these folders blindly.
Do not expose secrets, tokens, API keys, credentials, passwords, private keys, .env files, account IDs, sessions, browser profile state, cookies, local storage, IndexedDB, or access files.

Before any GitHub action:
1. audit filenames
2. audit tracked candidates
3. exclude secret/private/browser-state files
4. commit only safe metadata/capsule/manifest files
