FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Verificar directorio inicial
RUN pwd && echo "=== Contenido inicial ===" && ls -la

# Copiar requirements.txt y instalar dependencias
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copiar específicamente la carpeta api
COPY api/ /app/api/

# Verificaciones extensivas
RUN echo "=== Contenido después de COPY ===" && \
    ls -la /app && \
    echo "=== Contenido de /app/api ===" && \
    ls -la /app/api && \
    echo "=== Ubicación actual ===" && \
    pwd && \
    echo "=== Árbol completo ===" && \
    find /app

# Verificar el archivo específico
RUN ls -la /app/api/aplicacion_yape_plin.py || echo "El archivo no existe"

# Ejecutar la aplicación
CMD ["python3", "/app/api/aplicacion_yape_plin.py"]