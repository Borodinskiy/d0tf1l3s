# Base tools
scoop install git 7zip
# Bucket with extra programs
scoop bucket add main
scoop bucket add extras
scoop bucket add games

scoop install clangd ffmpeg yt-dlp

scoop install naps2 kdenlive krita
scoop install mpv
scoop install obs-studio
scoop install prismlauncher
scoop install qbittorrent
#scoop install msiafterburner rtss

scoop install hack-font windows-terminal neovim neovim-qt vifm

scoop install nekoray

# Installing shims
scoop shim add e nvim

# Extra commands
dotnet tool install --global csharp-ls
