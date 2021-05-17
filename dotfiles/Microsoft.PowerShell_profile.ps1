Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme powerline

# set alias
Function CDgithub {Set-Location -Path D:\GitHub}
Function CDonedrive {Set-Location -Path D:\OneDrive\'OneDrive - The Chinese University of Hong Kong'}
Function CDsoftware {Set-Location -Path D:\PortableSoftwares\Softwares}

Set-Alias -Name cdone -Value CDonedrive
Set-Alias -Name cdgh -Value CDgithub
Set-Alias -Name cdsw -Value CDsoftware
Set-Alias -Name installFont -Value 'D:\PortableSoftwares\Softwares\fonts\MesloNerdFont\Meslo LG M Regular Nerd Font Complete Windows Compatible.ttf'

# enter bash (MINGW) by default
# cd ~
# bash

# Function installFont {
#     copy "D:\PortableSoftwares\Softwares\fonts\MesloNerdFont\Meslo LG M Regular Nerd Font Complete Windows Compatible.ttf" "C:\Windows\Fonts"
#     reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "MelsoLGM NF" /t REG_SZ /d "Meslo LG M Regular Nerd Font Complete Windows Compatible.ttf" /f
# }
