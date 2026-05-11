# J Workspace Architecture

Purpose:
One unified working environment without turning GitHub into a dump of every local file.

Main idea:
- One main control repo: Incomesbook/workspaces.
- One VS Code master workspace that opens all important folders together.
- Separate living project repos remain separate.
- Huge files stay in local/archive storage and are tracked by manifests.
- Nothing is deleted or moved without explicit approval.

Main control repo:
J:\Setup_VcCode_Workspace\S10_GitHub\workspaces
https://github.com/Incomesbook/workspaces

Protected existing automation:
- ProjectChatAutomation.ps1
- Watch-JWorkspaceProjectBootstrap.ps1
- S06_Shared_Automation
- existing Codex / Workspace automation loop

Do not break:
- automatic project creation
- project-specific settings
- global settings
- chat sync folders
- Codex/Claude/VS Code setup

Current project roles:

1. workspaces
Role:
- central map
- restore instructions
- workspace structure
- safe scripts
- project references

2. Canada_Tax_Optimizer
Role:
- separate living project repo
- GitHub: Incomesbook/canada-tax-optimizer
Risk:
- local raw CODEX jsonl files above normal GitHub file size limits

3. LiveControl
Role:
- large local project candidate
Risk:
- dirty Git state
- 3866 changes
- huge sqlite/jsonl/txt/exe/archive/media files
Decision:
- read-only audit only for now
- no push
- no commit
- no merge

4. iNCOMEBOOK
Role:
- legacy Excel source
Decision:
- not a Git repo
- do not convert now

5. Workspace / signals
Role:
- legacy / reserved GitHub repos
Decision:
- do not delete now
- archive later only after final approval

Target physical structure later:

J:\Setup_VcCode_Workspace
- S10_GitHub\workspaces
- S02_Shared_VSCode
- S06_Shared_Automation
- S08_Shared_Global_AI_Chats
- S20_Projects
- S30_Large_Local_Archive
- S40_Restore_Manifests

Current rule:
Do not physically move existing projects yet.
First create maps, manifests, policies, and workspace references.
