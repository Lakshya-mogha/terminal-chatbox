#!/bin/bash

set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

SERVER_PID=""
NGROK_PID=""

cleanup() {
  echo -e "${GREEN}Cleaning up background processes...${RESET}"
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID"
  fi
  if [[ -n "$NGROK_PID" ]] && kill -0 "$NGROK_PID" 2>/dev/null; then
    kill "$NGROK_PID"
  fi
  exit 1
}

trap cleanup ERR INT

read -p "Run (b) both server and client or (c) only client? [1/2]: " choice

if [[ "$choice" == "b" ]]; then
  echo -e "${GREEN}[1/6] Setting up the project...${RESET}"
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt

  echo -e "${GREEN}[2/6] Starting server on port 8000...${RESET}"
  cd server
  python main.py &
  SERVER_PID=$!
  sleep 2

  echo -e "${GREEN}[3/6] Starting ngrok tunnel...${RESET}"
  ngrok http 8000 >/dev/null &
  NGROK_PID=$!
  sleep 4

  echo -e "${GREEN}[4/6] Fetching WebSocket URL...${RESET}"
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[a-z0-9.-]*\.ngrok-free\.app' | head -n1 || true)

  if [[ -z "$NGROK_URL" ]]; then
    echo -e "${RED}Failed to retrieve ngrok URL. Is ngrok running?${RESET}"
    cleanup
  fi

  WS_URL=${NGROK_URL/https:/wss:}
  WS_URL="$WS_URL"
  echo -e "${GREEN}WebSocket URL:${RESET} $WS_URL"

  echo -e "${GREEN}[5/6] Updating client with WebSocket URL...${RESET}"
  cd ../client
  sed -i "s|^SERVER_URL = .*|SERVER_URL = \"$WS_URL\"|" main.py

else
  echo -e "${GREEN}Skipping server/ngrok. Launching client only...${RESET}"
  read -p "Enter server url: " SERVER_URL
  cd client
  sed -i "s|^SERVER_URL = .*|SERVER_URL = \"$SERVER_URL\"|" main.py
  source ../venv/bin/activate
fi

echo -e "${GREEN}[6/6] Launching client...${RESET}"
python main.py
