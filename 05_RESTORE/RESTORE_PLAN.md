# Restore Plan

Goal:
A new computer should be able to restore the working environment from the main GitHub control repo plus local/archive backup.

Step 1:
Clone main control repo:
https://github.com/Incomesbook/workspaces

Step 2:
Open master VS Code workspace:
01_WORKSPACES\Igor_Master_Workspace.code-workspace

Step 3:
Clone or reconnect separate project repos:
- Incomesbook/canada-tax-optimizer
- future project repos

Step 4:
Reconnect local archive storage:
- raw chat histories
- sqlite diagnostics
- videos
- installers
- archived dumps

Step 5:
Restore tool settings only after audit:
- VS Code portable settings
- Claude/Codex/AI chat settings
- ProjectChatAutomation
- Watch-JWorkspaceProjectBootstrap

Never restore by blindly copying everything into one Git repo.
