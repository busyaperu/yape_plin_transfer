FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Instalar herramientas de debug
RUN apt-get update && apt-get install -y procps

# Copiar solo lo necesario
COPY requirements.txt .
RUN pip install -r requirements.txt

# Crear directorio api explícitamente
RUN mkdir -p /app/api

# Copiar el archivo de la aplicación
COPY api/aplicacion_yape_plin.py /app/api/
COPY api/ocr.py /app/api/

# Verificar la estructura y permisos
RUN echo "Contenido de /app:" && ls -la /app && \
    echo "Contenido de /app/api:" && ls -la /app/api && \
    chmod +x /app/api/aplicacion_yape_plin.py

# Script de inicio
COPY <<'EOF' /app/start.sh
#!/bin/bash
echo "Iniciando aplicación..."
echo "Verificando archivos..."
ls -la /app/api/
echo "Ejecutando Python script..."
python3 -u /app/api/aplicacion_yape_plin.py
EOF

RUN chmod +x /app/start.sh

# Usar el script de inicio
CMD ["/app/start.sh"]