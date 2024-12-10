# Importar dependencias
import openai
import os
from PIL import Image
import pytesseract
from supabase import create_client, Client

url = os.environ.get('SUPABASE_URL')
key = os.environ.get('SUPABASE_API_KEY')
openai.api_key = os.environ.get('OPENAI_API_KEY')
# Crear cliente de Supabase
supabase: Client = create_client(url, key)


def process_images_from_bucket():
    # Get the list of files in the bucket
    try:
        data = supabase.storage.from_(bucket_name).list()
        if data:
          for file_info in data:
              file_name = file_info['name']
              # Download the file from Supabase storage
              try:
                #path = os.path.join('/tmp', file_name)
                path = f'/tmp/{file_name}'
                with open(path, 'wb') as f:
                    data = supabase.storage.from_(bucket_name).download(file_name)
                    f.write(data)


                # Perform OCR
                try:
                  img = Image.open(path)
                  text = pytesseract.image_to_string(img)
                  print(f"Text extracted from {file_name}:\n{text}")

                  # You can further process the extracted text here
                except Exception as e:
                  print(f"Error during OCR processing for {file_name}: {e}")
                finally:
                    os.remove(path) # Remove downloaded file after processing

              except Exception as e:
                print(f"Error downloading {file_name} from Supabase: {e}")

        else:
          print("No files found in the bucket.")
    except Exception as e:
        print(f"An error occurred: {e}")


# Call the function to process images
process_images_from_bucket()



# Configuración de la conexión a Supabase
bucket_name = 'yape_plin'  # Reemplaza con tu bucket de Supabase

def process_image_and_send_to_supabase(image_name):
    # Descargar archivo desde Supabase
    try:
        # Descargar el archivo
        path = f'/tmp/{image_name}'
        with open(path, 'wb') as f:
            data = supabase.storage.from_(bucket_name).download(image_name)
            f.write(data)

        # Procesar la imagen con OCR
        try:
            img = Image.open(path)
            text = pytesseract.image_to_string(img)
            print(f"Text extracted from {image_name}:\n{text}")

            # Eliminar el archivo descargado
            os.remove(path)

            # Aquí puedes agregar lógica para procesar el texto y enviarlo a Supabase

        except Exception as e:
            print(f"Error during OCR processing for {image_name}: {e}")

    except Exception as e:
        print(f"Error downloading {image_name} from Supabase: {e}")

# Llamada para procesar la imagen
# Llamada para procesar las imágenes del bucket con plin_jose_hijo.jpeg

process_image_and_send_to_supabase("plin_jose_hijo.jpeg")


# Configuración de la API de OpenAI
openai.api_key = 'OPENAI_API_KEY'


bucket_name = 'yape_plin'  # Nombre del bucket en Supabase

# Prompt único para Yape y Plin
prompt = """
Texto extraído de una imagen de una transacción de Yape o Plin:
{data}

Por favor, organiza los siguientes datos en el siguiente formato:

- amount (extraído de la cantidad de dinero de la transacción).
- nombre (extraído de la persona a quien se le envió el dinero).
- fecha_constancia (extraída de la fecha y hora de la transacción).
- telefono (extraído del número de teléfono que aparece en la imagen).
- medio_pago (si es Yape o Plin, debe ser 'Yape' o 'Plin').
- numero_operacion (extraído del número de operación).

Ejemplo de formato esperado:

- amount: 30.00
- nombre: Oscar Humberto Alvarez Campos
- fecha_constancia: 15 Nov 2024 09:31 AM
- telefono: 936266482
- medio_pago: Plin
- numero_operacion: 00205777

- amount: 12
- nombre: Lizeth E. Merino M.
- fecha_constancia: 11 nov. 2024 - 06:19 pm
- telefono: 998007543
- medio_pago: Yape
- numero_operacion: 10739343
"""

def process_image_and_send_to_supabase(image_name):
    try:
        # Descargar el archivo desde Supabase
        path = f'/tmp/{image_name}'
        with open(path, 'wb') as f:
            data = supabase.storage.from_(bucket_name).download(image_name)
            f.write(data)

        # Procesar la imagen con OCR
        try:
            img = Image.open(path)
            text = pytesseract.image_to_string(img)
            print(f"Texto extraído de {image_name}:\n{text}")

            # Usamos el prompt único para procesar tanto Yape como Plin
            prompt_data = prompt.format(data=text)

            # Llamamos a OpenAI para procesar los datos
            response = openai.ChatCompletion.create(
                model="gpt-4",
                messages=[{"role": "user", "content": prompt_data}]
            )

            chatgpt_response = response['choices'][0]['message']['content'].strip()
            print(f"Datos procesados por ChatGPT:\n{chatgpt_response}")

            os.remove(path)

            # Llamar a la función para enviar los datos organizados a Supabase
            send_data_to_supabase(chatgpt_response)

        except Exception as e:
            print(f"Error durante el procesamiento de la imagen: {e}")

    except Exception as e:
        print(f"Error al descargar la imagen desde Supabase: {e}")

def send_data_to_supabase(data):
    try:
        # Extraer los valores del texto procesado por ChatGPT
        amount_str = data.split("amount:")[1].split("\n")[0].strip() if "amount:" in data else None
        nombre = data.split("nombre:")[1].split("\n")[0].strip() if "nombre:" in data else None
        fecha_constancia = data.split("fecha_constancia:")[1].split("\n")[0].strip() if "fecha_constancia:" in data else None
        numero_operacion = data.split("numero_operacion:")[1].split("\n")[0].strip() if "numero_operacion:" in data else None

        # Extraemos el teléfono directamente de la imagen
        telefono = data.split("telefono:")[1].split("\n")[0].strip() if "telefono:" in data else None

        # Convertir amount a float si se puede
        try:
            if amount_str and amount_str != "(Información no proporcionada)" and amount_str != "I":
                amount = float(amount_str.replace(",", ""))  # Convertir a float
            else:
                amount = None  # Si 'amount' no se puede extraer, asignamos NULL
        except ValueError:
            amount = None  # Si la conversión a float falla, asignamos NULL

        # Crear el diccionario con los datos extraídos
        extracted_data = {
            "amount": amount,  # El monto extraído
            "nombre": nombre,  # El nombre extraído
            "fecha_constancia": fecha_constancia,  # Fecha y hora de la transacción
            "telefono": telefono,  # El número de teléfono extraído de la imagen
            "celular": None,  # No necesitamos usar celular en la tabla
            "medio_pago": "Yape" if "Yape" in data else "Plin",  # Determinamos el medio de pago
            "numero_operacion": numero_operacion  # Número de operación
        }

        # Insertar los datos en la tabla 'acreditar' de Supabase
        response = supabase.table('acreditar').insert([extracted_data]).execute()
        print("Datos enviados a Supabase:", response)

    except Exception as e:
        print(f"Error al enviar los datos a Supabase: {e}")

# Llamar a la función para procesar la imagen específica
process_image_and_send_to_supabase("plin_jose_hijo.jpeg")
