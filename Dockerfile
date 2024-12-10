FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar requirements.txt y instalar dependencias
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copiar solo la carpeta api y su contenido
COPY api/ ./api/

# Verificar la estructura de archivos (para debugging)
RUN echo "=== Contenido de /app ===" && \
    ls -la /app && \
    echo "=== Contenido de /app/api ===" && \
    ls -la /app/api

# Ejecutar la aplicación
CMD ["python3", "./api/aplicacion_yape_plin.py"]