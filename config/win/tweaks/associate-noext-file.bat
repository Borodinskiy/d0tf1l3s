:: Run this as admin after installing scoop, so nvim-qt will be available by the path below

assoc .="No_Extension"
ftype "No_Extension"="%USERPROFILE%\scoop\apps\neovim-qt\current\bin\nvim-qt.exe" "%%1"
