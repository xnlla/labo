#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "follow command: source ./devsetup.sh"
	exit 1
fi

docker_setup() {
	if command -v docker >/dev/null 2>&1; then
		echo "Docker is already installed"
	else
		sudo apt update
		sudo apt install docker.io -y
		sudo gpasswd --add $USER docker
	fi
	if command -v docker-compose >/dev/null 2>&1; then
		echo "Docker Compose is already installed"
	else
		sudo wget https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -O /usr/local/bin/docker-compose
		sudo chmod +x /usr/local/bin/docker-compose
	fi

	docker --version
	docker-compose --version
}

dev_tools() {
	sudo apt update
	sudo apt install -y \
		git \
		curl \
		build-essential \
		shfmt \
		cifs-utils

	sed -i.bak -E "/^ *PS1=/ s/(^|[^\\])\\\\w/\1\\\\W/g" ~/.bashrc
	sudo hostnamectl set-hostname "devSrv"
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
		libreadline-dev \
		libsqlite3-dev

	if command -v pyenv >/dev/null 2>&1; then
		echo "pyenv is already installed"
	else
		git clone https://github.com/pyenv/pyenv.git ~/.pyenv

		echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.bashrc
		echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.bashrc
		echo 'eval "$(pyenv init -)"' >>~/.bashrc

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
sudo snap install --classic code
echo ""

echo "------ Docker setup ------"
docker_setup
echo ""

echo "------ All done! ------"
echo "follow command: sudo reboot"