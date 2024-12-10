FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Copiar solo lo necesario
COPY requirements.txt .
RUN pip install -r requirements.txt

# Crear directorio api explícitamente
RUN mkdir -p /app/api

# Copiar el archivo de la aplicación
COPY api/aplicacion_yape_plin.py /app/api/
COPY api/ocr.py /app/api/

# Verificar la estructura
RUN echo "Contenido de /app:" && ls -la /app && \
    echo "Contenido de /app/api:" && ls -la /app/api

# Definir el comando de inicio
CMD ["python3", "/app/api/aplicacion_yape_plin.py"]