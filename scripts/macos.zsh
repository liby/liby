#!/bin/zsh

# This script is heavily inspired by [SukkaW](https://github.com/SukkaW/dotfiles/blob/master/_install/macos.zsh)
# curl -o macos.zsh https://raw.githubusercontent.com/liby/liby/master/scripts/macos.zsh && chmod +x macos.zsh && ./macos.zsh

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
  echo "-----------------------------------------------------------"

  cd $HOME
}

is_apple_silicon() {
  [[ "$(/usr/bin/uname -m)" == "arm64" ]]
}

brew_shellenv() {
  # It will export env variable: HOMEBREW_PREFIX, HOMEBREW_CELLAR, HOMEBREW_REPOSITORY, HOMEBREW_SHELLENV_PREFIX
  # It will add path: $PATH, $MANPATH, $INFOPATH
  if is_apple_silicon; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
  else
      eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  echo "==========================================================="
  echo "                     Install Homebrew                      "
  echo "-----------------------------------------------------------"

  # xcode command tool will be installed during homebrew installation
  xcode-select --install || true

  if [ ! -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    brew_shellenv
    if ! ([[ -e ~/.zprofile ]] && grep -q "brew shellenv" ~/.zprofile); then
        echo "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\"" >> "${HOME}/.zprofile"
        echo "typeset -U path" >> "${HOME}/.zprofile"
    fi

    brew analytics off && brew update
    echo "Homebrew installed."
  else
    echo "Homebrew already installed. Skipping..."
  fi
}

install_brew_packages() {
  # Only install required packages for setting up enviroments
  # Later we will call brew bundle
  __pkg_to_be_installed=(
    curl
    git
    jq
    zsh
  )

  echo "==========================================================="
  echo "                * Install following packages:              "
  echo "                                                           "

  for __pkg ($__pkg_to_be_installed); do
    echo "  - ${__pkg}"
  done

  echo "-----------------------------------------------------------"

  brew update

  for __pkg in $__pkg_to_be_installed; do
    if brew list --formula | grep -q "^${__pkg}\$"; then
      echo "${__pkg} is already installed, skipping..."
    else
      brew install ${__pkg} || true
    fi
  done
}

brew_bundle() {
  echo "-----------------------------------------------------------"
  echo "          * Restore bundles from Homebrew                  "
  echo "-----------------------------------------------------------"
  brew bundle
}

setup_ohmyzsh() {
  echo "==========================================================="
  echo "                      Shells Enviroment                    "
  echo "-----------------------------------------------------------"
  echo "                   * Installing Oh My Zsh...               "
  echo "-----------------------------------------------------------"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh is already installed, skipping..."
  else
    echo "Oh My Zsh is not installed, proceeding with the installation..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  echo "-----------------------------------------------------------"
  echo "          * Installing ZSH Custom Plugins & Themes:        "
  echo "                                                           "
  echo "  - zsh-autosuggestions                                    "
  echo "  - zsh-completions                                        "
  echo "  - fast-syntax-highlighting                               "
  echo "                                                           "
  echo "-----------------------------------------------------------"

  export ZSH_PLUGINS_PREFIX="$HOME/.zsh/plugins"
  [[ ! -d "$ZSH_PLUGINS_PREFIX" ]] && mkdir -p $ZSH_PLUGINS_PREFIX

  if [[ ! -d "${ZSH_PLUGINS_PREFIX}/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_PLUGINS_PREFIX}/zsh-autosuggestions
  fi

  if [[ ! -d "${ZSH_PLUGINS_PREFIX}/zsh-completions" ]]; then
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_PLUGINS_PREFIX}/zsh-completions
  fi

  if [[ ! -d "${ZSH_PLUGINS_PREFIX}/fsh" ]]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_PLUGINS_PREFIX}/fsh
  fi
}

install_starship() {
  echo "==========================================================="
  echo "                   Install Starship                        "
  echo "-----------------------------------------------------------"

  if command -v starship > /dev/null; then
    echo "Starship is already installed, skipping..."
  else
    curl -sS https://starship.rs/install.sh | sh
  fi
}

restore_dotfiles() {
  echo "-----------------------------------------------------------"
  echo "          * Restore Bryan/dotfiles from GitHub.com         "
  echo "-----------------------------------------------------------"

  if [[ -d "$HOME/.dotfiles" ]]; then
    echo "Dotfiles already restored, skipping..."
  else
    git clone --bare git@github.com:liby/dotfiles.git $HOME/.dotfiles
    alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    dot config --local status.showUntrackedFiles no
    dot checkout --force

    brew_bundle
  fi
}


install_nodejs() {
  echo "==========================================================="
  echo "              Setting up NodeJS Environment                "
  echo "==========================================================="

  if command -v n > /dev/null; then
    echo "tj/n is already installed, skipping..."
    return
  fi

  export N_PREFIX="$HOME/.n"
  curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts

  # Set NPM Global Path
  export NPM_CONFIG_PREFIX="$HOME/.npm-global"
  # Create .npm-global folder if not exists
  [[ ! -d "$NPM_CONFIG_PREFIX" ]] && mkdir -p $NPM_CONFIG_PREFIX

  echo "-----------------------------------------------------------"
  echo "                * Installing Node.js LTS...                "
  echo "-----------------------------------------------------------"

  n lts

  echo "-----------------------------------------------------------"
  echo -n "                   * Node.js Version:                   "

  node -v

  echo "-----------------------------------------------------------"

  __npm_global_pkgs=(
    @upimg/cli
    0x
    # clinic
    npm-why
    # serve
    # vercel
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

install_rust() {
  echo "==========================================================="
  echo "                   Install Rust                            "
  echo "-----------------------------------------------------------"


  if command -v rustc > /dev/null; then
    echo "Rust is already installed, skipping..."
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
}

install_font() {
  echo "==========================================================="
  echo "                 Install Inconsolata LGC                   "
  echo "-----------------------------------------------------------"

  local font_file="$HOME/Downloads/InconsolataLGC.zip"
  
  if [[ -e "${font_file}" ]]; then
    echo "Font already downloaded, skipping download..."
  else
    echo "Downloading Inconsolata LGC..."
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/InconsolataLGC.zip -o "${font_file}"
    echo "Font downloaded successfully to ${font_file}."
  fi
}

reload_zshrc() {
  echo "==========================================================="
  echo "                  Reload Bryan env zshrc                   "
  echo "-----------------------------------------------------------"

  rm ~/.zcompdump*; autoload -w compinit && compinit -i
  exec zsh
}

finish() {
  echo "==========================================================="
  echo "Done!                                                      "
  echo "                                                           "
  echo "> Bryan Enviroment Setup finished!                         "
  echo "> Do not forget run those things:                          "
  echo "                                                           "
  echo "- NPM login                                                "
  echo "- Steup iTerm2                                             "
  echo "- Steup launchd for notes                                  "
  echo "- Install Bob,                                             "
  echo "          Slack,                                           "
  echo "          WeChat,                                          "
  echo "          Telegram,                                        "
  echo "          The Unarchiver,                                  "
  echo "          Hidden Bar                                       "
  echo "  from the Apple Store                                     "
  echo "- Install Inconsolata LGC                                  "
  echo "- Create a case-sensitive volume on macOS                  "
  echo "- https://www.v2ex.com/t/813229?p=1#r_11048555             "
  echo "                                                           "
  echo "==========================================================="

  cd $HOME
}

start
install_homebrew
install_brew_packages
setup_ohmyzsh
install_starship
# restore_dotfiles
install_nodejs
install_rust
install_font
finish
reload_zshrc
