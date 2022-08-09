#!/bin/zsh

# This script is heavily inspired by [SukkaW](https://github.com/SukkaW/dotfiles/blob/master/_install/macos.zsh)
# curl -o- https://raw.githubusercontent.com/liby/liby/master/scripts/macos.zsh | zsh

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "No macOS detected!"
  exit 1
fi

start() {
  clear

  echo "==========================================================="
  echo "                                                           "
  echo "▀█████████▄     ▄████████ ▄██   ▄      ▄████████ ███▄▄▄▄   "
  echo "  ███    ███   ███    ███ ███   ██▄   ███    ███ ███▀▀▀██▄ "
  echo "  ███    ███   ███    ███ ███▄▄▄███   ███    ███ ███   ███ "
  echo " ▄███▄▄▄██▀   ▄███▄▄▄▄██▀ ▀▀▀▀▀▀███   ███    ███ ███   ███ "
  echo "▀▀███▀▀▀██▄  ▀▀███▀▀▀▀▀   ▄██   ███ ▀███████████ ███   ███ "
  echo "  ███    ██▄ ▀███████████ ███   ███   ███    ███ ███   ███ "
  echo "  ███    ███   ███    ███ ███   ███   ███    ███ ███   ███ "
  echo "▄█████████▀    ███    ███  ▀█████▀    ███    █▀   ▀█   █▀  "
  echo "               ███    ███                                  "
  echo "                                                           "
  echo "==========================================================="
  echo "                      !! ATTENTION !!                      "
  echo "        YOU ARE SETTING UP: Bryan Environment (macOS)      "
  echo "==========================================================="
  echo "                                                           "
  echo -n "       * The setup will begin in 5 seconds...           "

  sleep 5

  echo -n "Times up! Here we start!"
  echo ""

  cd $HOME
}

# xcode command tool will be installed during homebrew installation
install_homebrew() {
  echo "==========================================================="
  echo "                     Install Homebrew                      "
  echo "-----------------------------------------------------------"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_packages() {
  # Only install required packages for setting up enviroments
  # Later we will call brew bundle
  __pkg_to_be_installed=(
    curl
    fnm
    git
    jq
    wget
    zsh
  )

  echo "==========================================================="
  echo "* Install following packages:"
  echo ""

  for __pkg ($__pkg_to_be_installed); do
    echo "  - ${__pkg}"
  done

  echo "-----------------------------------------------------------"

  brew update

  for __pkg ($__pkg_to_be_installed); do
    brew install ${__pkg} || true
  done
}

restore_dotfiles() {
  echo "-----------------------------------------------------------"
  echo "* Restore Bryan/dotfiles from GitHub.com"
  echo "-----------------------------------------------------------"

  git clone --bare git@github.com:liby/dotfiles.git $HOME/.dotfiles
  alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
  dot config --local status.showUntrackedFiles no
}

setup_ohmyzsh() {
  echo "==========================================================="
  echo "                      Shells Enviroment                    "
  echo "-----------------------------------------------------------"
  echo "                   * Installing Oh-My-Zsh...               "
  echo "-----------------------------------------------------------"

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "-----------------------------------------------------------"
  echo "* Installing ZSH Custom Plugins & Themes:"
  echo ""
  echo "  - zsh-autosuggestions"
  echo "  - fast-syntax-highlighting"
  echo "  - zsh-z"
  echo "-----------------------------------------------------------"

  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/fzf-tab
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z
}

brew_bundle() {
  brew bundle
}

install_nodejs() {
  echo "==========================================================="
  echo "              Setting up NodeJS Environment                "

  eval $(fnm env --use-on-cd --shell zsh)

  # Set NPM Global Path
  export NPM_CONFIG_PREFIX="$HOME/.npm-global"
  # Create .npm-global folder if not exists
  [[ ! -d "$NPM_CONFIG_PREFIX" ]] && mkdir -p $NPM_CONFIG_PREFIX

  echo "-----------------------------------------------------------"
  echo "                * Installing Node.js LTS...                 "
  echo "-----------------------------------------------------------"

  fnm install --lts

  echo "-----------------------------------------------------------"
  echo -n "                   * Node.js Version:                    "

  node -v

  __npm_global_pkgs=(
    @upimg/cli
    0x
    # clinic
    # vercel
    npm-why
    # serve
  )

  echo "-----------------------------------------------------------"
  echo "                * npm install global packages:             "
  echo "                                                           "

  for __npm_pkg ($__npm_global_pkgs); do
    echo "  - ${__npm_pkg}"
  done

  echo "-----------------------------------------------------------"

  for __npm_pkg ($__npm_global_pkgs); do
    npm i -g ${__npm_pkg}
  done
}

install-goenv() {
  echo "==========================================================="
  echo "                   Install syndbg/goenv                    "
  echo "-----------------------------------------------------------"

  git clone https://github.com/syndbg/goenv.git $HOME/.goenv
}

zshrc() {
  echo "==========================================================="
  echo "                  Import sukka env zshrc                   "
  echo "-----------------------------------------------------------"

  cat $HOME/dotfiles/_zshrc/macos.zshrc > $HOME/.zshrc
  cat $HOME/dotfiles/p10k/.p10k.zsh > $HOME/.p10k.zsh
}

vimrc() {
  echo "==========================================================="
  echo "                  Import sukka env vimrc                   "
  echo "-----------------------------------------------------------"

  cat $HOME/dotfiles/vim/.vimrc > $HOME/.vimrc
}

finish() {
  echo "==========================================================="
  echo -n "                     * Clean up...                      "

  cd $HOME
  rm -rf $HOME/dotfiles

  echo "Done!                                                      "
  echo "                                                           "
  echo "> Bryan Enviroment Setup finished!                         "
  echo "> Do not forget run those things:                          "
  echo "                                                           "
  echo "- chsh -s /usr/bin/zsh                                     "
  echo "- npm login                                                "
  echo "- ci-edit-update                                           "
  echo "- oload-config                                             "
  echo "- git-config                                               "
  echo "* open vim and run :PlugInstall                            "
  echo "==========================================================="

  cd $HOME
}

start
install_homebrew
# install_packages
restore_dotfiles
setup_ohmyzsh
brew_bundle
install_nodejs
zshrc
finish
