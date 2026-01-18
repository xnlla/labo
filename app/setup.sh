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
	sudo systemctl daemon-reload
	sudo systemctl restart docker

	docker --version
	docker-compose --version
}

dev_tools() {
	sudo apt update
	sudo apt install cifs-utils -y

	sed -i.bak -E "/^ *PS1=/ s/(^|[^\\])\\\\w/\1\\\\W/g" ~/.bashrc
	sudo hostnamectl set-hostname "appSrv"
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

fix_grub() {
	sudo sed -i.bak \
		-e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' \
		-e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' \
		/etc/default/grub
	sudo update-grub
}

docker_cleanup() {
	sudo docker container prune -f
	sudo docker image prune -f
	sudo docker builder prune -f
}

discordbot() {
	git clone https://github.com/xnlla/discordbot.git discordbot
	if [ -f .env.tenki-chan ]; then
		DIR=$ROOTPATH/discordbot/tenki-chan
		cp -v $ROOTPATH/.env.tenki-chan $DIR/.env
		cd $DIR
		sudo docker-compose down
		docker_cleanup
		sudo docker-compose build
		sudo docker-compose up -d
		cd $ROOTPATH
	fi
	if [ -f .env.kaikei-san ]; then
		DIR=$ROOTPATH/discordbot/kaikei-san
		cp -v $ROOTPATH/.env.kaikei-san $DIR/.env
		cd $DIR
		sudo docker-compose down
		docker_cleanup
		sudo docker-compose build
		sudo docker-compose up -d
		cd $ROOTPATH
	fi
}

ytdlp() {
	git clone https://github.com/nekono-dev/ytdlpServer.git -b dev/v1.1 ytdlpServer
	cd ytdlpServer
	docker_cleanup
	sudo docker-compose build
	sudo docker-compose up -d --scale worker=4
	cd $ROOTPATH
}

openwebui() {
	OPENWEBUI_PATH=$ROOTPATH/openwebui
	mkdir $OPENWEBUI_PATH

	cp -v openwebui.yaml $OPENWEBUI_PATH/docker-compose.yaml
	cd $OPENWEBUI_PATH
	sudo docker-compose down
	docker_cleanup
	sudo docker-compose up -d
	cd $ROOTPATH
}


fstab() {
	if ! grep -qFf .fstab /etc/fstab; then
		if [ -f .fstab ]; then
			cat .fstab | sudo tee -a /etc/fstab
		fi
	fi
	sleep 1
	sudo mount -a
}

echo "------ Devtools setup ------"
dev_tools
echo ""

echo "------ Node setup ------"
node_setup
echo ""

echo "------ Docker setup ------"
docker_setup
echo ""

echo "------ App setup ------"
fstab
discordbot
ytdlp
openwebui

echo "------ All done! ------"
echo "follow command: sudo reboot"
