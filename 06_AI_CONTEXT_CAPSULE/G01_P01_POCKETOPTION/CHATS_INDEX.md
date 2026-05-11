# CHATS_INDEX

## Known AI/chat-related roots from audit

- G01_P01_02_Project_Settings\G01_P01_02_05_AI_Memory
- G01_P01_02_Project_Settings\G01_P01_02_05_AI_Memory\G01_P01_02_05_01_Chat_Root
- G01_P01_02_Project_Settings\G01_P01_02_03_Sources\G01_P01_02_03_06_External_Memory
- G01_P01_02_Project_Settings\G01_P01_02_04_Knowledge\G01_P01_02_04_02_YouTube\Claude_Code_и_Разработка
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\PocketOption_VcCode\Agent_PocketOption_VcCode_V1
- G01_P01_02_Project_Settings\G01_P01_02_11_Legacy\Imported_From_G01_P03_Market_Agent\Agent_PocketOption_VcCode_V1

## Browser/chat export related roots from audit

- chrome_profile\Default\IndexedDB\https_chatgpt.com_0.indexeddb.leveldb
- chrome_profile\Default\Extensions\...\scripts\exportChat
- chrome_profile\Default\Extensions\...\scripts\manageChats
- chrome_profile\Default\Extensions\...\scripts\moveChat
- chrome_profile\Default\Extensions\...\scripts\pinnedChats
- chrome_profile\Default\Extensions\...\scripts\chatMenu

## Rule

This capsule only references chat locations.
It does not contain raw chat logs.
Chrome profile / IndexedDB / extension data must not be pushed to normal Git.
Raw chat exports require Git LFS, archive, or encrypted/private backup decision.
