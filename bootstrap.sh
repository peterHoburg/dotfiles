#! /bin/bash

########## Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLDDIR=~/dotfiles_old                   # old dotfiles backup directory
FILES=".zshrc .tmux.conf .editorconfig" # list of files/folders to symlink in homedir
DF_TMP_DIR=~/Downloads/dotfiles_temp
##########

if [[ $(uname) == 'Linux' ]]; then
  mkdir $DF_TMP_DIR

  if [[ -n "$(command -v apt)" ]]; then
    echo "using apt"

    # add gcloud ppa
    # TODO check if this is already done
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install $(grep -vE "^\s*#" requirements/linux.txt | tr "\n" " ")

    # Docker ppa
    # TODO check if this has already been done
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl enable docker
    # https://docs.docker.com/install/linux/linux-postinstall/


    if [[ ! -d "$DF_TMP_DIR/google_chrome" ]]; then
      echo "Installing google chrome"
      mkdir $DF_TMP_DIR/google_chrome
      wget -p $DF_TMP_DIR/google_chrome https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo apt install $DF_TMP_DIR/google_chrome/google-chrome-stable_current_amd64.deb
    fi

  elif [[ -n "$(command -v pamac)" ]]; then
    echo "Using pamac"
    sudo pamac update
    sudo pamac install $(grep -vE "^\s*#" requirements/linux.txt | tr "\n" " ")
  fi

  sudo snap install $(grep -vE "^\s*#" requirements/snap.txt | tr "\n" " ")

  if [ ! -d "$HOME/Documents/lenovo-throttling-fix" ]; then
    echo "Installing the lenovo throttling fix"
    git clone https://github.com/erpalma/lenovo-throttling-fix.git ~/Documents
    sudo ~/Documents/lenovo-throttling-fix/install.sh
  else
    # TODO add git pull here
    # TODO if there is new code run install.sh again
    echo ""
  fi


  # Install jetbrains toolbox
  if [[ ! -f "$DF_TMP_DIR/jetbrains-toolbox-1.16.6319.tar.gz" ]]; then
    echo "Installing jetbrains toolbox"
    wget -O $DF_TMP_DIR/jetbrains-toolbox-1.16.6319.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6319.tar.gz"
    tar -xf $DF_TMP_DIR/jetbrains-toolbox-1.16.6319.tar.gz --directory $DF_TMP_DIR
    chmod u+x $DF_TMP_DIR/jetbrains-toolbox-1.16.6319/jetbrains-toolbox
    ~/Documents/jetbrains-toolbox-1.16.6319/jetbrains-toolbox
  fi


elif [[ $(uname) == 'Darwin' ]]; then
  echo "On a mac... Sorry"
  if ! type brew >/dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/cask
    brew tap buo/cask-upgrade
  fi
  cat $DIR/requirements/brew_packages.txt | xargs brew install
  cat $DIR/requirements/brew_casks.txt | xargs brew cask install
fi

# install Rust
if [[ ! -x "$(command -v cargo)" ]]; then
  echo "Installing rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# install rust packages
cargo install $(grep -vE "^\s*#" requirements/cargo.txt | tr "\n" " ")

### !!!WARNING!!! ####
# THIS IS ANNOYING BECAUSE IT WILL START AN OH-MY-ZSH SHELL WHICH YOU WILL WANT TO EXIT TO FINISH THE SCRIPT
# thinking about ditching oh-my-zsh but it's working so far so I will have to revisit if it gets bad
echo "###########Exit the zsh shell after it pop up to continue!###########"
if [ ! -d ~/.oh-my-zsh ]; then
  echo "Installing oh-my-zsh"
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
if [ ! -f "$HOME/.ssh/github" ]; then
  ssh-keygen -f ~/.ssh/github
fi

if [ ! -f "$HOME/.ssh/space" ]; then
  ssh-keygen -f ~/.ssh/space
fi

# install tmux plugin manager if the directory doesn't already exist
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

source ~/.zshrc

vim $DIR/todo_post_bootstrap.txt
