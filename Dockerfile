FROM python:3.9-slim

# Declarar las variables de entorno directamente
ENV VAR1=${VAR1}
ENV VAR2=${VAR2}
ENV VAR3=${VAR3}
ENV VAR4=${VAR4}

WORKDIR /app
COPY . .

# Instalar dependencias
RUN pip install -r requirements.txt

# Verificar que el archivo se copie correctamente
RUN ls -alh /app  # Verifica si el archivo se copia correctamente

# Comando para ejecutar el archivo de Python
CMD ["python3", "/app/api/aplicacion_yape_plin.py"]

