REM Preparing disk for ext2ifs: mke2fs -I 128 -m0 -L VIDEO -t ext3 -T largefile /dev/sda7
@echo off
mountvol E:\ \\?\Volume{061ef765-884f-11e1-be7d-50e5495a280f}
mountvol F:\ \\?\Volume{061ef766-884f-11e1-be7d-50e5495a280f}
mountvol G:\ \\?\Volume{061ef767-884f-11e1-be7d-50e5495a280f}
mountvol H:\ \\?\Volume{f80d140e-8c5c-11e1-bbc3-806e6f6e6963}

timeout /t 2

net share documents=E: /GRANT:Guest,CHANGE
net share photo=F: /GRANT:Guest,CHANGE
net share video=G: /GRANT:Guest,CHANGE
net share music=H: /GRANT:Guest,CHANGE
@echo on
