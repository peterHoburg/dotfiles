#! /bin/bash

########## Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLDDIR=~/dotfiles_old                   # old dotfiles backup directory
FILES=".zshrc .tmux.conf .editorconfig" # list of files/folders to symlink in homedir
ZSH_INSTALLED=false && (type zsh >/dev/null) && zsh_installed=true
##########

if [[ $(uname) == 'Linux' ]]; then
  if [[ -n "$(command -v apt)" ]]; then
    echo "using apt"
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install $(grep -vE "^\s*#" requirements/linux.txt | tr "\n" " ")
  elif [[ -n "$(command -v pamac)" ]]; then
    echo "using pamac"
    sudo pamac update
    sudo pamac install $(grep -vE "^\s*#" requirements/linux.txt | tr "\n" " ")
  fi
  sudo snap install $(grep -vE "^\s*#" requirements/snap.txt | tr "\n" " ")

  # install a temp fix for lenovo throttling
  git clone https://github.com/erpalma/lenovo-throttling-fix.git ~/Documents
  sudo ~/Documents/lenovo-throttling-fix/install.sh

  # TODO see if this is already there
  # install jetbrains toolbox
  wget -O ~/Documents/jetbrains-toolbox-1.16.6319.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6319.tar.gz"
  tar -xf ~/Documents/jetbrains-toolbox-1.16.6319.tar.gz --directory .
  chmod u+x ~/Documents/jetbrains-toolbox-1.16.6319/jetbrains-toolbox
  ~/Documents/jetbrains-toolbox-1.16.6319/jetbrains-toolbox

elif [[ $(uname) == 'Darwin' ]]; then
  if ! type brew >/dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/cask
    brew tap buo/cask-upgrade
  fi
  cat $DIR/requirements/brew_packages.txt | xargs brew install
  cat $DIR/requirements/brew_casks.txt | xargs brew cask install
fi

# install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install rust packages
cargo install $(grep -vE "^\s*#" requirements/cargo.txt | tr "\n" " ")

### !!!WARNING!!! ####
# THIS IS ANNOYING BECAUSE IT WILL START AN OH-MY-ZSH SHELL WHICH YOU WILL WANT TO EXIT TO FINISH THE SCRIPT
# thinking about ditching oh-my-zsh but it's working so far so I will have to revisit if it gets bad
echo "###########Exit the zsh shell after it pop up to continue!###########"
if [ ! -d ~/.oh-my-zsh ]; then
  # if zsh wasn't installed at the beginning of the script, we install oh-my-zsh after it is brew installed
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  chsh -s $(which zsh)
fi
### !!!WARNING!!! ####

# create dotfiles_old in homedir
echo "Creating $OLDDIR for backup of any existing dotfiles in ~"
mkdir -p $OLDDIR
echo "...done"

# change to the dotfiles directory
echo "Changing to the $DIR directory"
cd $DIR
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $FILES; do
  echo "Moving any existing dotfiles from ~ to $OLDDIR"
  mv ~/$file ~/dotfiles_old/
  echo "Creating symlink to $file in home directory."
  ln -s $DIR/conf_files/$file ~/$file
done

# add ssh config
ln -s $DIR/ssh/config ~/.ssh/config
ln -s $DIR/ssh/config_personal ~/.ssh/config_personal

# generate ssh keys
ssh-keygen -f ~/.ssh/github
ssh-keygen -f ~/.ssh/space

# install tmux plugin manager if the directory doesn't already exist
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

source ~/.zshrc

vim $DIR/todo_post_bootstrap.txt
