#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

KEEP_ORIGINAL_APP="${KEEP_ORIGINAL_APP:-false}"
ROOT_PATH=${ROOT_PATH:-_app}
MARK=@a21e259c-1c80-4d6b-928f-89716d576c13@
cd "$SCRIPT_DIR"/../build || exit 1

if ! [ -d ${ROOT_PATH} ]; then # Create a relocated copy of the frontend based on the mark
    if ${KEEP_ORIGINAL_APP}; then
        mkdir -p ${ROOT_PATH}
        cp -rp ${MARK}/app ${ROOT_PATH}/app
    else
        mv ${MARK} ${ROOT_PATH}
    fi
    ln -s ${ROOT_PATH}/app
    find ${ROOT_PATH}/app/immutable/entry -type f -exec sed -i "s~${MARK}~${ROOT_PATH}/app~g"   '{}' \;
    find ${ROOT_PATH}/ -type f -exec sed -i "s~${MARK}~${ROOT_PATH}~g"   '{}' \;
    sed "s~${MARK}~${ROOT_PATH}~g" index.html.am > index.html
fi

cd "$SCRIPT_DIR" || exit

KEY_FILE=.webui_secret_key

PORT="${PORT:-8080}"
HOST="${HOST:-0.0.0.0}"
if test "$WEBUI_SECRET_KEY $WEBUI_JWT_SECRET_KEY" = " "; then
  echo "Loading WEBUI_SECRET_KEY from file, not provided as an environment variable."

  if ! [ -e "$KEY_FILE" ]; then
    echo "Generating WEBUI_SECRET_KEY"
    # Generate a random value to use as a WEBUI_SECRET_KEY in case the user didn't provide one.
    echo $(head -c 12 /dev/random | base64) > "$KEY_FILE"
  fi

  echo "Loading WEBUI_SECRET_KEY from $KEY_FILE"
  WEBUI_SECRET_KEY=$(cat "$KEY_FILE")
fi

if [[ "${USE_OLLAMA_DOCKER,,}" == "true" ]]; then
    echo "USE_OLLAMA is set to true, starting ollama serve."
    ollama serve &
fi

if [[ "${USE_CUDA_DOCKER,,}" == "true" ]]; then
  echo "CUDA is enabled, appending LD_LIBRARY_PATH to include torch/cudnn & cublas libraries."
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/python3.11/site-packages/torch/lib:/usr/local/lib/python3.11/site-packages/nvidia/cudnn/lib"
fi

# Check if SPACE_ID is set, if so, configure for space
if [ -n "$SPACE_ID" ]; then
  echo "Configuring for HuggingFace Space deployment"
  if [ -n "$ADMIN_USER_EMAIL" ] && [ -n "$ADMIN_USER_PASSWORD" ]; then
    echo "Admin user configured, creating"
    WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY" uvicorn open_webui.main:app --host "$HOST" --port "$PORT" --forwarded-allow-ips '*' &
    webui_pid=$!
    echo "Waiting for webui to start..."
    while ! curl -s http://localhost:8080/health > /dev/null; do
      sleep 1
    done
    echo "Creating admin user..."
    curl \
      -X POST "http://localhost:8080/api/v1/auths/signup" \
      -H "accept: application/json" \
      -H "Content-Type: application/json" \
      -d "{ \"email\": \"${ADMIN_USER_EMAIL}\", \"password\": \"${ADMIN_USER_PASSWORD}\", \"name\": \"Admin\" }"
    echo "Shutting down webui..."
    kill $webui_pid
  fi

  export WEBUI_URL=${SPACE_HOST}/${ROOT_PATH}
fi

ENABLE_RAG_WEB_SEARCH=true
WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY" \
		FRONTEND_APP_ROOT=/${ROOT_PATH} \
		ENABLE_RAG_WEB_SEARCH=true \
		exec uvicorn open_webui.main:app --host "$HOST" --port "$PORT" --forwarded-allow-ips '*'
