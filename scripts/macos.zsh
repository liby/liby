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

    if ! ([[ -e ~/.zprofile ]] && grep -q "brew shellenv" ~/.zprofile); then
        echo "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\"" >> "${HOME}/.zprofile"
        echo "typeset -U path" >> "${HOME}/.zprofile"
    fi
    brew_shellenv

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
    gnupg
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
  echo "==========================================================="
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

setup_gpg_agent() {
  echo "==========================================================="
  echo "                * Setting up GPG Agent                     "
  echo "-----------------------------------------------------------"

  echo "Installing pinentry-mac using Homebrew..."
  brew install pinentry-mac

  local gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"
  if [[ -f "$gpg_agent_conf" ]]; then
    echo "$gpg_agent_conf already exists. Checking configuration..."
  else
    echo "$gpg_agent_conf does not exist. Creating and configuring..."
    touch "$gpg_agent_conf"
  fi

  if grep -q "pinentry-program" "$gpg_agent_conf"; then
    echo "pinentry-program is already configured in $gpg_agent_conf."
  else
    echo "Configuring pinentry-program in $gpg_agent_conf..."
    echo "pinentry-program $(which pinentry-mac)" >> "$gpg_agent_conf"
  fi

  chmod 600 "$gpg_agent_conf"
  echo "Launching gpg-agent if not already running..."
  gpgconf --launch gpg-agent

  echo "Reloading gpg-agent configuration..."
  echo RELOADAGENT | gpg-connect-agent

  echo "GPG Agent setup completed."
}

format_gitconfig_files() {
  echo "==========================================================="
  echo "                    Format Gitconfig Files                 "
  echo "-----------------------------------------------------------"

  local config_dir="$HOME/gitconfig"

  if [[ -d "$config_dir" ]]; then
    echo "Formatting all files in $config_dir..."

    find "$config_dir" -type f | while read -r file; do
      perl -pi -e 's/^\s*/  /g' "$file"
      echo "Formatted $file"
    done

    echo "All files in $config_dir have been formatted."
  else
    echo "Directory $config_dir does not exist."
  fi
}

restore_dotfiles() {
  echo "-----------------------------------------------------------"
  echo "          * Restore Bryan’s dotfiles from GitHub.com         "
  echo "-----------------------------------------------------------"

  if [[ -d "$HOME/.dotfiles" ]]; then
    echo "Dotfiles already restored, skipping..."
  else
    git clone --bare https://github.com/liby/dotfiles.git $HOME/.dotfiles
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout --force

    local dotfiles_dir="$HOME/.dotfiles"
    local git_sub_config_path="$HOME/gitconfig"
    local github_template="$git_sub_config_path/.github-template"
    local gitlab_template="$git_sub_config_path/.gitlab-template"
    local github_config="$git_sub_config_path/.github"
    local gitlab_config="$git_sub_config_path/.gitlab"
    local ssh_dir="$HOME/.ssh"
    local gpg_pub_key_file="$ssh_dir/$GPG_KEY_ID.pub"

    if [[ -d "$HOME/.gnupg" ]]; then
      chmod 700 "$HOME/.gnupg"
      chmod 600 "$HOME/.gnupg"/*
    fi
    local GPG_KEY_ID=$(gpg --card-status | grep 'sec' | awk '{print $2}' | cut -d'/' -f2)

    git config --file $git_sub_config_path/.github user.signingkey $GPG_KEY_ID
    gpg --export-ssh-key $GPG_KEY_ID > $HOME/.ssh/$GPG_KEY_ID.pub
    git config --file $git_sub_config_path/.gitlab user.signingkey $HOME/.ssh/$GPG_KEY_ID.pub

    local encoded_email="Ym95dWFuLmxpQHJpZ2h0Y2FwaXRhbC5jb20="
    local decoded_email=$(echo -n "$encoded_email" | base64 --decode)
    local encoded_name="Qm95dWFuIExp"
    local decoded_name=$(echo -n "$encoded_name" | base64 --decode)

    git config --file $git_sub_config_path/.gitlab user.email $decoded_email
    git config --file $git_sub_config_path/.gitlab user.name $decoded_name
    
    format_gitconfig_files
    setup_gpg_agent
    brew_bundle
  fi

  git --git-dir=$HOME/.dotfiles --work-tree=$HOME remote set-url origin git@github.com:liby/dotfiles.git
}

install_nodejs() {
  echo "==========================================================="
  echo "              Setting up NodeJS Environment                "
  echo "-----------------------------------------------------------"

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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
restore_dotfiles
install_nodejs
install_rust
install_font
finish
reload_zshrc
