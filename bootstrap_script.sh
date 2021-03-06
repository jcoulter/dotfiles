#/usr/bin/env bash

source "${BASH_IT}/bash_it.sh"

function doIt() {
  # Copy over contents
  rsync --exclude ".git/" \
    --exclude "bootstrap.sh" \
    --exclude "bootstrap_script.sh" \
    --exclude "README.md" \
    --exclude ".gitkeep" \
    -avh --no-perms . ~ \

  # Enable bash helpers
  bash-it enable alias \
    bundler \
    curl \
    docker \
    docker-compose \
    general \
    git \
    vim
  bash-it enable plugin \
    alias-completion \
    base \
    docker-compose \
    docker \
    edit-mode-vi \
    git \
    fzf \
    history
  bash-it enable completion \
    bash-it \
    bundler \
    docker \
    docker-compose \
    gem \
    git \
    npm \
    rake \
    system

  # Download/install coc.nvim extensions
  (
    cd "${HOME}/.config/coc/extensions"
    yarn install
  )

  # Download/install ripgrep
  echo "Downloading and installing 'ripgrep'"
  local github="$(githubUrl BurntSushi ripgrep)"
  local version="$(getVersion "${github}")"
  local url="${github}/releases/download/${version}/ripgrep-${version}-x86_64-unknown-linux-musl.tar.gz"
  local tmp="$(mktemp -d)"
  (
    cd "${tmp}" && \
      curl -L "${url}" | tar xz --strip-components=1 && \
      mv rg ~/bin
  )
  rm -fr "${tmp}"

  # Download/install fzf
  echo "Downloading and installing 'fzf'"
  local github="$(githubUrl junegunn fzf-bin)"
  local version="$(getVersion "${github}")"
  local url="${github}/releases/download/${version}/fzf-${version}-linux_amd64.tgz"
  local tmp="$(mktemp -d)"
  (
    cd "${tmp}" && \
      curl -L "${url}" | tar xz && \
      mv fzf ~/bin && \
      cat shell/completion.bash shell/key-bindings.bash > ~/.fzf.bash
  )
  rm -fr "${tmp}"

  # Download/install fzf scripts
  echo "Downloading and installing 'fzf scripts'"
  local github="$(githubUrl junegunn fzf)"
  local url="${github}/archive/master.tar.gz"
  local tmp="$(mktemp -d)"
  (
    cd "${tmp}" && \
      curl -L "${url}" | tar xz --strip-components=1 && \
      cat shell/completion.bash shell/key-bindings.bash > ~/.fzf.bash
  )
  rm -fr "${tmp}"

  # Download/install fd
  echo "Downloading and installing 'fd'"
  local github="$(githubUrl sharkdp fd)"
  local version="$(getVersion "${github}")"
  local url="${github}/releases/download/${version}/fd-${version}-x86_64-unknown-linux-gnu.tar.gz"
  local tmp="$(mktemp -d)"
  (
    cd "${tmp}" && \
      curl -L "${url}" | tar xz --strip-components=1 && \
      mv fd ~/bin
  )
  rm -fr "${tmp}"

  # Download/install bat
  echo "Downloading and installing 'bat'"
  local github="$(githubUrl sharkdp bat)"
  local version="$(getVersion "${github}")"
  local url="${github}/releases/download/${version}/bat-${version}-x86_64-unknown-linux-gnu.tar.gz"
  local tmp="$(mktemp -d)"
  (
    cd "${tmp}" && \
      curl -L "${url}" | tar xz --strip-components=1 && \
      mv bat ~/bin
  )
  rm -fr "${tmp}"

  # Download/install tldr
  echo "Downloading and installing 'tldr'"
  local github="$(githubUrl dbrgn tealdeer)"
  local version="$(getVersion "${github}")"
  local url="${github}/releases/download/${version}/tldr-x86_64-musl"
  curl -L "${url}" -o ~/bin/tldr && \
    chmod 755 ~/bin/tldr
}

function githubUrl {
  local account="${1}"
  local project="${2}"
  echo "https://github.com/${account}/${project}"
}

function getVersion() {
  local github="${1}"
  local json="$(curl -L -s -H 'Accept: application/json' ${github}/releases/latest)"
  # The releases are returned in the format:
  #     {"id":3622206,"tag_name":"hello-1.0.0.11",...}
  # we have to extract the tag_name.
  echo "$(echo "${json}" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')"
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
