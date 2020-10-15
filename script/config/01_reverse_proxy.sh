#!/bin/bash

source /usr/local/bin/common.sh

if [[ "$REVERSE_PROXY_MODE" =~ ^https?$ ]]; then
    log_info "Configuring reverse proxy"
    SERVICE_URL="$REVERSE_PROXY_MODE://$SERVER_ADDRESS"
    SEAFHTTP_URL=${SERVICE_URL//[\/]/\\/}"\/seafhttp"
    crudini --set $EXPOSED_ROOT_DIR/conf/ccnet.conf General SERVICE_URL "$SERVICE_URL"
    # Update FILE_SERVER_ROOT if it exists, otherwise add it to the end of the file
    # This way we make sure any other changes to this file (e.g. OAUTH config) do not get lost
    grep -qx "FILE_SERVER_ROOT.*" $EXPOSED_ROOT_DIR/conf/seahub_settings.py \
      && sed -i "s~FILE_SERVER_ROOT.*~FILE_SERVER_ROOT = '$SEAFHTTP_URL'~" $EXPOSED_ROOT_DIR/conf/seahub_settings.py \
      || echo "FILE_SERVER_ROOT = '$SEAFHTTP_URL'" >> $EXPOSED_ROOT_DIR/conf/seahub_settings.py
else
    log_info "Reverse proxy is not configured"
    crudini --set $EXPOSED_ROOT_DIR/conf/ccnet.conf General SERVICE_URL "http://$SERVER_ADDRESS:8000"
    sed -i '/^FILE_SERVER_ROOT/d' "$EXPOSED_ROOT_DIR/conf/seahub_settings.py"
fi
