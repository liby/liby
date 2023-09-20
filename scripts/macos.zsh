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
  echo "                                                           "

  cd $HOME
  xcode-select --install || true
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

# xcode command tool will be installed during homebrew installation
install_homebrew() {
  echo "==========================================================="
  echo "                     Install Homebrew                      "
  echo "-----------------------------------------------------------"
  if [ ! -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    brew_shellenv
    if ! ([[ -e ~/.zprofile ]] && grep -q "brew shellenv" ~/.zprofile); then
        echo "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\"" >> "${HOME}/.zprofile"
    fi


    brew analytics off && brew update
    echo "Homebrew installed."
  else
    echo "Homebrew already installed. Skipping..."
  fi
}

install_packages() {
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

  for __pkg ($__pkg_to_be_installed); do
    brew install ${__pkg} || true
  done
}

setup_ohmyzsh() {
  echo "==========================================================="
  echo "                      Shells Enviroment                    "
  echo "-----------------------------------------------------------"
  echo "                   * Installing Oh-My-Zsh...               "
  echo "-----------------------------------------------------------"

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_PLUGINS_PREFIX}/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_PLUGINS_PREFIX}/zsh-completions
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_PLUGINS_PREFIX}/fast-syntax-highlighting
}

install_starship() {
  echo "==========================================================="
  echo "                   Install Starship                        "
  echo "-----------------------------------------------------------"

  curl -sS https://starship.rs/install.sh | sh
}

restore_dotfiles() {
  echo "-----------------------------------------------------------"
  echo "          * Restore Bryan/dotfiles from GitHub.com         "
  echo "-----------------------------------------------------------"

  git clone --bare git@github.com:liby/dotfiles.git $HOME/.dotfiles
  alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
  dot config --local status.showUntrackedFiles no
  dot checkout
}

brew_bundle() {
  brew bundle
}

install_nodejs() {
  echo "==========================================================="
  echo "              Setting up NodeJS Environment                "

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

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_font() {
  echo "==========================================================="
  echo "                 Install Inconsolata LGC                   "
  echo "-----------------------------------------------------------"

  curl -LJO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/InconsolataLGC.zip -o $HOME/Downloads
}

reload_zshrc() {
  echo "==========================================================="
  echo "                  Reload Bryan env zshrc                   "
  echo "-----------------------------------------------------------"

  # exec zsh
  rm ~/.zcompdump*; compinit -i
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
  echo "- Install Slack,                                           "
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
install_packages
setup_ohmyzsh
install_starship
restore_dotfiles
brew_bundle
install_nodejs
install_rust
install_font
reload_zshrc
finish
