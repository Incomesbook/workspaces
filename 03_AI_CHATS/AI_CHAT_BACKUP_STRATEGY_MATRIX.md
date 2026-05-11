# AI Chat Backup Strategy Matrix

## By class


Class                   Files        MB
-----                   -----        --
STRICT_PRIVATE_EXCLUDE  60825 275022.86
HUGE_RAW_OR_ARCHIVE        30  74099.94
BROWSER_STATE_PRIVATE   86435  63421.18
LARGE_RAW_OR_ARCHIVE      253   43596.6
CHAT_RELATED_METADATA  131115  15612.15
ARCHIVE_BINARY_EXCLUDE    900   5475.37
CHAT_MEMORY_CANDIDATE  125384   3802.99




## By strategy


Strategy                                            Files        MB
--------                                            -----        --
DO_NOT_PUSH_REVIEW_PRIVATE                          60825 275022.86
LOCAL_ARCHIVE_OR_ENCRYPTED_ARCHIVE                     30  74099.94
ENCRYPTED_ARCHIVE_OR_LOCAL_ONLY                     86435  63421.18
GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE                253   43596.6
MANIFEST_OR_REVIEW                                 131115  15612.15
LOCAL_ARCHIVE_ONLY                                    900   5475.37
NORMAL_GIT_ONLY_IF_REDACTED_AND_SMALL_ELSE_ARCHIVE 125384   3802.99




## By root


Root                                   Files        MB
----                                   -----        --
J:\Setup_VcCode_Workspace             369829 387171.63
J:\ПРОЕКТЫ                             20142  72530.78
J:\_AI_CHATS_ОБЩИЕ                      7800   10859.9
C:\Users\IgorK\.codex                   6675  10367.77
C:\Users\IgorK\.claude                   491       101
C:\Users\IgorK\AppData\Roaming\Claude      4         0
C:\Users\IgorK\AppData\Local\Claude        1         0




## Rules

| Class | Default action |
|---|---|
| CHAT_MEMORY_CANDIDATE | Review; small redacted summaries may go normal Git; raw content goes encrypted/archive/LFS decision |
| CHAT_RELATED_METADATA | Manifest or review |
| LARGE_RAW_OR_ARCHIVE | Git LFS candidate only after manual approval, otherwise encrypted/local archive |
| HUGE_RAW_OR_ARCHIVE | Local/encrypted archive, not normal Git |
| BROWSER_STATE_PRIVATE | Do not push; encrypted archive only if restore-critical |
| STRICT_PRIVATE_EXCLUDE | Do not push; manifest only |
| ARCHIVE_BINARY_EXCLUDE | Local archive only |
| OTHER_METADATA_ONLY | Manifest only unless explicitly approved |
