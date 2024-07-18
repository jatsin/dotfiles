#!/bin/env bash
# Install script for the dotfiles
# Author: @jatsin

## functions
is_installed () {
    command -v $1 &> /dev/null
    # sudo snap list $1 > /dev/null 2>&1
}

ag_install ()
{
    echo "installing $@ .."
    sudo apt-get update && sudo apt-get install -y $@
    [[ $? -eq 0 ]] && echo "Successfully installed $@" || echo "Failed to install $@"
}

install_cloudflare_warp ()
{
    # Add cloudflare gpg key
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg


    # Add this repo to your apt repositories
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list


    # Install
    ag_install cloudflare-warp
}

install_docker ()
{
    # Add Docker's official GPG key:
    # sudo apt-get update
    # sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install docker
    ag_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_kubectl ()
{
    echo "installing kubectl"
    pushd $DOWNLOADS_DIR
    # Download the latest release
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    # Validate the binary and kubectl against checksum (optional)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    # install it in user's bin
    chmod +x kubectl
    [[ ! -d  $LOCAL_BIN ]] && mkdir -p $LOCAL_BIN
    [[ ! -f $LOCAL_BIN/kubectl ]] &&  mv ./kubectl ~/.local/bin/kubectl
    # and then append (or prepend) ~/.local/bin to $PATH
    echo "export PATH=$PATH:$LOCAL_BIN" >> ~/.zshrc
    # reload # if aliases are set or . ./.zshrc
    echo "successfully installed kubectl"
}

install_kubectx ()
{
    if ! grep -q "deb \[trusted=yes\] http://ftp.de.debian.org/debian bookworm main" /etc/apt/sources.list; then
        echo "deb [trusted=yes] http://ftp.de.debian.org/debian bookworm main" >> /etc/apt/sources.list
    fi
    # Add the server public keys
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0E98404D386FA1D9
    ag_install kubectx
}

install_1password ()
{
    # Add the key for the 1Password apt repository:
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    # Add the 1Password apt repository:
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    
    # Add the debsig-verify policy:
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    
    # Install 1Password:
    ag_install 1password
}


add_chrome_repo ()
{
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
}

# variables
ESSENTIALS="git vim tmux zsh curl wget build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release"
DOWNLOADS_DIR="$HOME/Downloads"
CLOUDFLARE_CERT_URL="https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.crt"
CLOUDFLARE_CERT_FILE="Cloudflare_CA.crt"
CLOUDFLATE_CERT="$DOWNLOADS_DIR/$CLOUDFLARE_CERT_FILE"
LOCAL_BIN="$HOME/.local/bin"

### MAIN ###

# install essential packages
# ag_install $ESSENTIALS

## Cloudflare warp
# Install cloudflare warp
if ! is_installed warp-cli
then
    install_cloudflare_warp
    # download cloudflare cert
    wget $CLOUDFLARE_CERT_URL -O $CLOUDFLATE_CERT
    # install cloudflare cert
    sudo cp $CLOUDFLATE_CERT /usr/share/ca-certificates/
    sudo dpkg-reconfigure ca-certificates
else
    echo "Cloudflare is already installed"
fi

## zsh
# Install zsh
if ! is_installed zsh
then
    ag_install zsh
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "zsh is already installed"
fi

## Docker
# Install docker
if ! is_installed docker
then
    install_docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl restart docker
    # Not necessary
    sudo chmod 666 /var/run/docker.sock
else
    echo "Docker is already installed"
fi

## kubectl
# Install kubectl
if ! is_installed kubectl
then
    install_kubectl
    # download kubelogin plugin
    if [[ ! -f $LOCAL_BIN/kubelogin ]]; then
        wget https://github.com/int128/kubelogin/releases/download/v1.28.1/kubelogin_linux_amd64.zip -O $TEMP/kubelogin_linux_amd64.zip
        unzip $TEMP/kubelogin_linux_amd64.zip -d $TEMP/kubelogin_extraction
        mv $TEMP/kubelogin_extraction/kubelogin $LOCAL_BIN/kubelogin-oidc_login
        rm -rf $TEMP/kubelogin_extraction $TEMP/kubelogin_linux_amd64.zip
    fi
else
    echo "kubectl is already installed"
fi

## kubectx
if ! is_installed kubectx
then
    install_kubectx
else
    echo "kubectx is already installed"
fi

## Chrome
# Add chrome repo
if ! is_installed google-chrome-stable
then
    add_chrome_repo
    # Install chrome
    ag_install google-chrome-stable
else
    echo "google chrome already installed"
fi

# install neovim
# ag_install neovim

# install tmux
# ag_install tmux

# 1password
if ! is_installed 1password
then
    install_1password
else
    echo "1password is already installed"
fi
