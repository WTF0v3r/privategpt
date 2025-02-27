FROM ubuntu
LABEL org.opencontainers.image.source=https://github.com/wtf0v3r/privategpt
EXPOSE 3000 5000

RUN     apt update && \
        apt install -y curl && \
        curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
        apt install -y git nodejs python3 build-essential python3-dev supervisor pandoc && \
        curl https://bootstrap.pypa.io/get-pip.py | python3  && \
        cd /root  && \
        git clone https://github.com/SamurAIGPT/privateGPT.git  && \
        cd /root/privateGPT/client && \
        npm install  && \
        cd /root/privateGPT/server && \
        pip3 install --no-cache-dir -r requirements.txt && \
        pip3 install --no-cache-dir html2text && \
	pip3 cache purge && \
        apt-get -y purge build-essential python3-dev && \
        apt-get -y autoclean && apt-get -y autoremove && \
        apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
        rm -rf /var/lib/apt/lists/*

RUN     sed -i 's/localhost/"+window.location.hostname+"/g' /root/privateGPT/client/components/ConfigSideNav.js  && \
        sed -i 's/localhost/"+window.location.hostname+"/g' /root/privateGPT/client/components/MainContainer.js
	
RUN     echo "[program:privategtp-server]" > /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "directory=/root/privateGPT/server" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "autostart=true" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "autorestart=true" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "stdout_events_enabled=true" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "stderr_events_enabled=true" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "command=python3 /root/privateGPT/server/privateGPT.py" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "process_name = python3" >> /etc/supervisor/conf.d/pgpt-server.conf && \
        echo "[program:pgpt-client]" > /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "directory=/root/privateGPT/client" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "autostart=true" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "autorestart=true" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "stdout_events_enabled=true" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "stderr_events_enabled=true" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "command=npm run dev" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "process_name = npm" >> /etc/supervisor/conf.d/pgpt-client.conf && \
        echo "END"

	#cd /root/privateGPT/server/models  && \
	#wget https://gpt4all.io/models/ggml-gpt4all-j-v1.3-groovy.bin && \


CMD ["/usr/bin/supervisord","-n"]
