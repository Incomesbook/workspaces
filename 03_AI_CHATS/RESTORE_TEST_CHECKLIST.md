# Restore Test Checklist

## Goal

Prove that Igor can continue work on a new or clean machine without losing project context.

## Test 1 - GitHub control repo restore

- Clone Incomesbook/workspaces.
- Open Igor_Master_Workspace.code-workspace.
- Confirm CURRENT_STATUS_MAP.md exists.
- Confirm capsules exist:
  - G01_P01_POCKETOPTION
  - G01_P02_TRADINGVIEW_CLAUDE
  - G01_P03_MARKET_AGENT
  - G01_ALL_ABOUT_TRADING

## Test 2 - CleanSource restore

- Confirm CleanSource folders exist or can be recreated:
  - G01_P01_PocketOption_CleanSource
  - G01_P02_TVClaude_CleanSource
  - G01_P03_MarketAgent_CleanSource
  - LiveControl_CleanSource

## Test 3 - Archive restore

Not ready yet.

Needed first:
- encrypted archive destination
- archive creation script
- archive verification script
- restore extraction test

## Test 4 - AI context restore

Not ready yet.

Needed first:
- raw AI chat archive decision
- Claude/Codex/Copilot/ChatGPT export procedure
- searchable index strategy

## Test 5 - Full project run

Not ready yet.

Needed first:
- identify REQUIRED_TO_RUN files
- identify recreatable dependencies
- identify private files needed locally but not in Git

## Pass condition

The system is not fully finished until:
1. GitHub control repo restores project map.
2. CleanSource restores safe project source.
3. Archive layer restores raw/history/private material.
4. AI context can be found and read by future agents.
5. Missing/recreatable files are documented.
