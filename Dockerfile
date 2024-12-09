FROM python:3.9-slim

# Declarar las variables ARG (disponibles solo durante la construcción)
ARG VAR1
ARG VAR2
ARG VAR3
ARG VAR4

# Establecer las variables de entorno ENV (disponibles en el contenedor en tiempo de ejecución)
ENV VAR1=$VAR1
ENV VAR2=$VAR2
ENV VAR3=$VAR3
ENV VAR4=$VAR4

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN ls -alh /app  # Verifica si el archivo se copia correctamente
CMD ["python3", "aplicacion_yape_plin.py"]
