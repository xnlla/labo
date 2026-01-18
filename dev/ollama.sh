#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo "it must be root"
	exit 1
fi

curl -fsSL https://ollama.com/install.sh | sh
sed -i '/^\[Service\]/a Environment="OLLAMA_HOST=0.0.0.0"' /etc/systemd/system/ollama.service
systemctl daemon-reload
systemctl restart ollama.service

ollama pull gemma3:4b
ollama pull hf.co/anthracite-org/magnum-v4-12b-gguf:Q8_0
ollama pull hf.co/Undi95/Lumimaid-Magnum-v4-12B-GGUF:Q8_0
ollama pull gemma3:12b
ollama pull gpt-oss:20b
#ollama pull hf.co/mmnga/umiyuki-Umievo-itr012-Gleipnir-7B-gguf:Q8_0
ollama pull hf.co/mradermacher/Dirty-Muse-Writer-v01-Uncensored-Erotica-NSFW-GGUF:Q8_0
ollama pull qwen3:14b

#apt install docker.io
#curl -SL https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-`uname -s | tr [A-Z] [a-z]`-`uname -m` -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
#gpasswd -a $USER docker

##docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
