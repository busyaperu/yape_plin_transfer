FROM python:3.9-slim

# Variables de entorno
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Copiar requirements y archivos de la aplicación
COPY requirements.txt .
COPY api/ ./api/

# Instalar dependencias
RUN pip install -r requirements.txt

# Comando para ejecutar la aplicación
CMD ["python3", "./api/aplicacion_yape_plin.py"]