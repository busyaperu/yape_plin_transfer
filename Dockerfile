FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
RUN ls /app  # Agrega esta línea para ver los archivos en /app
CMD ["python3", "/app/aplicacion_yape_plin.py"]
