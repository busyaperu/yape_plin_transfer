FROM python:3.9-slim

# Variables de entorno
ENV GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS}
ENV OPENAI_API_KEY=${OPENAI_API_KEY}
ENV SUPABASE_API_KEY=${SUPABASE_API_KEY}
ENV SUPABASE_URL=${SUPABASE_URL}

WORKDIR /app

# Copiar requirements y archivos de la aplicación
COPY requirements.txt .
COPY api/ ./api/

# Instalar dependencias
RUN pip install -r requirements.txt

# Modificar el comando para ver las variables
CMD echo "SUPABASE_URL: $SUPABASE_URL" && \
    echo "SUPABASE_API_KEY: $SUPABASE_API_KEY" && \
    python3 ./api/aplicacion_yape_plin.py