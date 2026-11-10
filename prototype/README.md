# TEZA Lot Lab prototype

This is a local prototype for collecting image and sensor observations, selecting observations to create one coffee lot, and asking a local Ollama model about that lot.

## Start

1. Make sure Ollama is running and the model is installed:

   ~~~powershell
   ollama list
   ~~~

2. Start the app from PowerShell:

   ~~~powershell
   cd D:\Teza_server\prototype
   python server.py
   ~~~

3. Open http://127.0.0.1:8765.

The server uses Python's standard library. It binds to localhost and calls Ollama at http://127.0.0.1:11434. Prototype lots and intake records are stored in the browser's local storage. The initial records are clearly marked as sample data.

To choose another installed model:

~~~powershell
$env:OLLAMA_MODEL = "qwen3:4b-instruct-2507-q4_K_M"
python server.py
~~~

This prototype has no production database, accounts, or device connection. Image and sensor records in the inbox demonstrate the workflow; they are not live Raspberry Pi or sensor feeds.
