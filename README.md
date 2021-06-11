# toolkit
To store dotfiles, templates...

# dir tree
.
 - [update_win.ps1](./update_win.ps1)
 - [TA](./TA)
   - [InputGrades.xlsx](./TA/InputGrades.xlsx)
   - [MATH2060A_pluto](./TA/MATH2060A_pluto)
   - [tex](./TA/tex)
 - [.vscode](./.vscode)
 - [install_bashaliases.sh](./install_bashaliases.sh)
 - [julia](./julia)
   - [v1.5](./julia/v1.5)
   - [v1.6](./julia/v1.6)
   - [julia_install.sh](./julia/julia_install.sh)
   - [julia_setbin.sh](./julia/julia_setbin.sh)
   - [julia_uninstall.sh](./julia/julia_uninstall.sh)
   - [startup.jl](./julia/startup.jl)
 - [update_linux.sh](./update_linux.sh)
 - [tex](./tex)
   - [JabRef_Settings.xml](./tex/JabRef_Settings.xml)
   - [texstudio_marcos](./tex/texstudio_marcos)
   - [texstudio_profile](./tex/texstudio_profile)
   - [myposters](./tex/myposters)
   - [myexam](./tex/myexam)
   - [mybeamer](./tex/mybeamer)
   - [mysolution](./tex/mysolution)
   - [bib](./tex/bib)
   - [mythesis](./tex/mythesis)
   - [myarticle](./tex/myarticle)
 - [dotfiles](./dotfiles)
   - [.bash_aliases](./dotfiles/.bash_aliases)
   - [.bash_aliases_linux](./dotfiles/.bash_aliases_linux)
   - [.bash_aliases_macos](./dotfiles/.bash_aliases_macos)
   - [Microsoft.PowerShell_profile.ps1](./dotfiles/Microsoft.PowerShell_profile.ps1)
   - [.bash_aliases_win](./dotfiles/.bash_aliases_win)
   - [.bashrc](./dotfiles/.bashrc)
   - [.vimrc](./dotfiles/.vimrc)
   - [.bash_aliases_global](./dotfiles/.bash_aliases_global)
 - [README.md](./README.md)

## install `zsh` packages

1. [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  ```
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ```
2. [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) 
  ```
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ```
3. [autojump](https://github.com/wting/autojump)

## `zsh` theme [powerline10k](https://github.com/romkatv/powerlevel10k)
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```