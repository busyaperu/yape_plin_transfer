FROM python:3.9-slim

# Declarar las variables de entorno directamente
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app

# Copiar requirements.txt primero
COPY requirements.txt .

# Instalar dependencias
RUN pip install -r requirements.txt

# Copiar el resto del código
COPY ./api /app/api

# Verificar que el archivo se copie correctamente
RUN ls -alh /app/api

# Comando para ejecutar el archivo de Python
CMD ["python3", "/app/api/aplicacion_yape_plin.py"]
