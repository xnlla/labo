# pyenv

Ref: https://qiita.com/ksato9700/items/5d9eba10fe6b8e064178

## Setup

Install dependencies

```sh
sudo apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev libreadline-dev libsqlite3-dev
```

Install pyenv from github

```sh
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```

Setup shell

```sh
cat <<EOF >> ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
```

## Usage

```sh
pyenv install --list
## pyenv install 3.12.11
pyenv versions
pyenv global 3.12.11
```

# virtualenv

## Setup

```sh
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
source ~/.bashrc
```

## Usage

```sh
## create venv ex: discordbot
pyenv virtualenv 3.12.11 discordbot
pyenv versions
## change env
pyenv local discordbot
```
