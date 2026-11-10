"""Serve the TEZA prototype and proxy local chat requests to Ollama."""

from __future__ import annotations

import json
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parent
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434").rstrip("/")
MODEL = os.environ.get("OLLAMA_MODEL", "qwen3.5:2b-q4_K_M")
HOST = "127.0.0.1"
PORT = int(os.environ.get("TEZA_PORT", "8765"))
MAX_REQUEST_BYTES = 128_000


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def log_message(self, _format, *_args):
        return

    def send_json(self, status, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/api/health":
            try:
                with urlopen(OLLAMA_URL + "/api/tags", timeout=3) as response:
                    tags = json.loads(response.read().decode("utf-8"))
                models = [item.get("name", "") for item in tags.get("models", [])]
                available = any(name == MODEL or name.startswith(MODEL + ":") for name in models)
                self.send_json(200, {
                    "ollama": "online",
                    "model": MODEL,
                    "model_available": available,
                    "installed_models": models,
                })
            except (OSError, URLError, json.JSONDecodeError) as error:
                self.send_json(503, {
                    "ollama": "offline",
                    "model": MODEL,
                    "model_available": False,
                    "error": str(error),
                })
            return

        if self.path == "/":
            self.path = "/index.html"
        super().do_GET()

    def do_POST(self):
        if self.path != "/api/chat":
            self.send_json(404, {"error": "ไม่พบ endpoint"})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length <= 0 or length > MAX_REQUEST_BYTES:
                self.send_json(413, {"error": "คำขอมีขนาดไม่ถูกต้อง"})
                return
            body = json.loads(self.rfile.read(length).decode("utf-8"))
            messages = body.get("messages")
            if not isinstance(messages, list) or not messages:
                self.send_json(400, {"error": "กรุณาส่ง messages"})
                return
            payload = {
                "model": MODEL,
                "messages": messages[-12:],
                "stream": False,
                "think": False,
                "options": {
                    "num_ctx": 2048,
                    "num_predict": 192,
                    "temperature": 0.2,
                },
            }
            request = Request(
                OLLAMA_URL + "/api/chat",
                data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urlopen(request, timeout=240) as response:
                result = json.loads(response.read().decode("utf-8"))
            message = result.get("message", {}).get("content", "")
            self.send_json(200, {"content": message, "model": result.get("model", MODEL)})
        except HTTPError as error:
            details = error.read().decode("utf-8", errors="replace")
            self.send_json(502, {"error": "Ollama ตอบกลับไม่สำเร็จ", "details": details[:2000]})
        except (OSError, URLError, TimeoutError) as error:
            self.send_json(502, {
                "error": "เชื่อมต่อ Ollama ไม่ได้",
                "details": str(error),
            })
        except (ValueError, UnicodeDecodeError, json.JSONDecodeError) as error:
            self.send_json(400, {"error": "อ่านคำขอไม่ได้", "details": str(error)})


if __name__ == "__main__":
    print("TEZA Lot Lab: http://" + HOST + ":" + str(PORT))
    print("Ollama model: " + MODEL)
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
