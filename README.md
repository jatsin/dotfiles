# Ubuntu dotfiles

Hopefully no more hassle to manage dotfiles

## Pre-requisites

Ensure below packages are installed

### Git

```
sudo apt install git
```

### Stow
```
sudo apt install stow
```

## Installation

First of all, checkout dotfiles repo in your $HOME directory

```
git clone https://github.com/jatindersinghbraich/dotfiles.git
cd dotfiles
```

Secondly, stow to create symlinks

```
stow .
```


