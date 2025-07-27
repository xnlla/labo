# Setup

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

# Usage

```sh
pyenv install --list
## pyenv install 3.12.11
pyenv versions
pyenv glbal 3.12.11
```