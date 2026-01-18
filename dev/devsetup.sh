#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Run follow as: source ./devsetup.sh"
	exit 1
fi

dev_tools() {
  sudo apt update
  sudo apt install -y \
    git \
    curl \
    build-essential \
    shfmt
}
node_setup() {
	if command -v nvm >/dev/null 2>&1; then
		echo "nvm is already installed"
	else
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	fi
	source ~/.bashrc
	if command -v node >/dev/null 2>&1; then
		echo "Node is already installed"
	else
		nvm install --lts
	fi
	node -v
	npm -v
}
pyenv_setup() {
  sudo apt install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    liblzma-dev \
    libbz2-dev \
    libreadline-dev  \
    libsqlite3-dev

	if command -v pyenv >/dev/null 2>&1; then
		echo "pyenv is already installed"
	else
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc

    source ~/.bashrc
    
		git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
		echo 'eval "$(pyenv virtualenv-init -)"' >>~/.bashrc
		source ~/.bashrc
	fi

  pyenv install -s 3.12.11
  pyenv global 3.12.11

	pyenv versions
	python --version
	pip --version
}

echo "------ Devtools setup ------"
dev_tools
echo ""

echo "------ Node setup ------"
node_setup
echo ""

echo "------ Python setup ------"
pyenv_setup
echo ""

echo "------ Code setup ------"
snap install --classic code
echo ""

echo "------ All done! ------"