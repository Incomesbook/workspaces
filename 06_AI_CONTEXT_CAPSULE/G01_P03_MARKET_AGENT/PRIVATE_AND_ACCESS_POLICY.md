# PRIVATE_AND_ACCESS_POLICY

## API/key/private/access-like folders from audit

Known folder:
G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_And_Service_References

Known folder:
G01_P03_02_Project_Settings\G01_P03_02_03_Sources\G01_P03_02_03_05_API_Keys_And_IDs

## Rule

Do not push these folders blindly.
Do not expose secrets, tokens, API keys, credentials, passwords, private keys, .env files, account IDs, or access files.

Before any GitHub action:
1. audit filenames
2. audit tracked candidates
3. exclude secret/private files
4. commit only safe manifest/capsule metadata
