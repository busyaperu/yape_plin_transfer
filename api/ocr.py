from http.server import BaseHTTPRequestHandler
import subprocess

class handler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Lógica para manejar la solicitud POST y ejecutar el script de OCR
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OCR procesado')
