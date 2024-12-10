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

# Agregar comandos de debug
RUN echo "Contenido del directorio /app:"
RUN ls -la /app
RUN echo "Contenido del directorio /app/api:"
RUN ls -la /app/api

# Dar permisos de ejecución al script
RUN chmod +x /app/api/aplicacion_yape_plin.py

# Comando para ejecutar el archivo de Python con logs
CMD ["sh", "-c", "echo 'Iniciando aplicación...' && python3 /app/api/aplicacion_yape_plin.py"]