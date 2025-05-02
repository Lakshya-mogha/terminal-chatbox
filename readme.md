# Terminal Chatroom Over the Web

A real-time terminal-based chatroom using Python, WebSockets, and ngrok.

## How to Run

Install ngrok on the system and set it up

Run just the single command to set up and run both server and client
**RECOMMENDED WAY**

```bash
./run.sh
```

## For manual setup

### 1. Install all dependecies

```bash
pip install -r requirements.txt
```

### 2. Setup server

```bash
python server/main.py
## start ngrok server
ngrok http 8000
```

Copy the ws://... WebSocket URL (e.g., wss://abc123.ngrok.io). **MAKE SURE THE URL IS SAME AS GIVEN IN EXAMPLE**

Paste the url in client server_url

### 3. Start client

```bash
python client/main.py
```
