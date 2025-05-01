import asyncio
import websockets
import threading

SERVER_URL = "wss://0e84-139-5-240-191.ngrok-free.app"
SERVER_URL += "/ws"
print(SERVER_URL)
def input_thread(send_queue):
    while True:
        message = input()
        send_queue.append(message)

name = input("Enter your name: ")
async def chat_client():
    send_queue = []
    threading.Thread(target=input_thread, args=(send_queue,), daemon=True).start()
    try:
        async with websockets.connect(SERVER_URL) as websocket:
            await websocket.send(f"{name} joined the chat")
            while True:
                if send_queue:
                    await websocket.send(f"{name}: {send_queue.pop(0)}")

                try:
                    msg = await asyncio.wait_for(websocket.recv(), timeout=0.1)
                    print(f"\r{msg}\n> ", end="", flush=True)
                except asyncio.TimeoutError:
                    continue
                except websockets.ConnectionClosed:
                    print(f"\n{name} Disconnected.")
                    break
    except Exception as e:
        print(f"Failed to connect: {e}")
if __name__ == "__main__":
    try:
        asyncio.run(chat_client())
    except KeyboardInterrupt:
        print("Client stopped by user.")
        try:
            asyncio.run(websockets.connect(SERVER_URL).send(f"{name} disconnected"))
        except:
            pass
