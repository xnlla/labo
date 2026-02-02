#!/bin/bash

ROOTPATH=$(pwd)
cd $ROOTPATH

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "follow command: source ./setup.sh"
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
	echo '{"dns": ["8.8.8.8", "8.8.4.4"]}' | sudo tee /etc/docker/daemon.json

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

git_configure() {
	git config --global core.editor vim
	git config --global sequence.editor vim
}

gituclone_setup() {
	rm -rf /tmp/gitUclone
	git clone -b v1 https://github.com/nekono-dev/gitUclone.git /tmp/gitUclone
	chmod +x /tmp/gitUclone/src/git-uclone.sh
	sudo cp /tmp/gitUclone/src/git-uclone.sh /usr/local/bin/git-uclone

	## configure myself
	git uclone --setup --user nlla --key ~/.ssh/id_ed25519 --email 156630485+xnlla@users.noreply.github.com
}

fix_grub() {
	sudo sed -i.bak \
		-e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' \
		-e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' \
		/etc/default/grub
	sudo update-grub
}

code_setup() {
	# install code server
	sudo snap install code --classic
	sudo cp ./code-serveweb.service /etc/systemd/system/code-serveweb.service
	sudo systemctl daemon-reload
	sudo systemctl enable --now code-serveweb.service

	# Add cloudflare gpg key
	sudo mkdir -p --mode=0755 /usr/share/keyrings
	curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

	# Add this repo to your apt repositories
	echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

	# install cloudflared
	sudo apt-get update && sudo apt-get install cloudflared -y
	systemctl is-enabled cloudflared.service >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "cloudflared service is already enabled"
	else
		sudo cloudflared service install $(cat ./code/code.secret)
	fi

	## for use host environment, no use docker
	# mv ./code.secret ./code/code.secret
	# cp -r ./code $HOME
	# pushd $HOME/code
	# docker-compose up -d
	# popd
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
code_setup
echo ""

echo "------ Docker setup ------"
docker_setup
echo ""

echo "------ Git configure ------"
git_configure
gituclone_setup

echo "------ All done! ------"
echo "follow command: sudo reboot"
