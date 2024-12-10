FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Mostrar directorio actual antes de copiar
RUN pwd && ls -la

# Copiar requirements.txt
COPY requirements.txt .

# Instalar dependencias
RUN pip install -r requirements.txt

# Copiar el código y verificar inmediatamente
COPY ./api /app/api
RUN echo "=== Contenido de /app ===" && \
    ls -la /app && \
    echo "=== Contenido de /app/api ===" && \
    ls -la /app/api

# Modificar el CMD para que use la ruta correcta
CMD ["python3", "/app/api/aplicacion_yape_plin.py"]