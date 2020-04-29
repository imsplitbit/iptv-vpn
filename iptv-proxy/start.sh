#!/bin/bash

# Check for missing Group / PGID
PGROUPNAME=iptv
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "A group with PGID $PGID already exists in /etc/passwd, nothing to do."
else
   echo "A group with PGID $PGID does not exist, adding a group called 'iptv' with PGID $PGID"
   groupadd -g $PGID $PGROUPNAME
fi

# Check for missing User / PUID
PUSERNAME=iptv
/bin/egrep  -i "^.+:${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "An user with PUID $PUID already exists in /etc/passwd, nothing to do."
   PUSERNAME=$(/bin/egrep  -i "^.+:${PUID}:" /etc/passwd | cut -d ":" -f1)
else
   echo "An user with PUID $PUID does not exist, adding an user called 'iptv user' with PUID $PUID"
   useradd -c "iptv user" -g $PGID -u $PUID $PUSERNAME
fi

if [[ ! -e /config/iptv-proxy ]]; then
	mkdir -p /config/iptv-proxy
fi
chown -R ${PUID}:${PGID} /config/iptv-proxy

# Set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi

if [ -z "${PROXY_USER}" ]
then
    PROXY_USER=iptv
fi
echo "[info] Proxy username: ${PROXY_USER}" | ts '%Y-%m-%d %H:%M:%.S'

if [ -z "${PROXY_PASS}" ]
then
    PROXY_PASS=iptv
fi
echo "[info] Proxy password: ${PROXY_PASS}" | ts '%Y-%m-%d %H:%M:%.S'

if [ -z "${PROXY_HOST}" ]
then
    PROXY_HOST=localhost
fi
echo "[info] Proxy host: ${PROXY_HOST}" | ts '%Y-%m-%d %H:%M:%.S'

echo "[info] Starting iptv-proxy daemon..." | ts '%Y-%m-%d %H:%M:%.S'
if [ -z "${PROXY_PATH}"]
then
    su $PUSERNAME -c '/bin/bash iptv-proxy --m3u-url "${M3U_URL}" --port $WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST &'
else
    echo "[info] Proxy path: ${PROXY_PATH}" | ts '%Y-%m-%d %H:%M:%.S'
    su $PUSERNAME -c '/bin/bash iptv-proxy --m3u-url "${M3U_URL}" --port $WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST --custom-endpoint $PROXY_PATH &'
fi

sleep 1
iptv-proxypid=$(pgrep -o -x iptv-proxy) 
echo "[info] IPTV-Proxy PID: $iptv-proxypid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$iptv-proxypid ]; then
	sleep infinity
else
	echo "[error] iptv-proxy failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
fi