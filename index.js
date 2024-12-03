const express = require('express');
const { exec } = require('child_process');
const { createClient } = require('@supabase/supabase-js');

// Variables de entorno
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_API_KEY = process.env.SUPABASE_API_KEY;

// Inicializa el cliente de Supabase
const supabase = createClient(SUPABASE_URL, SUPABASE_API_KEY);

const app = express();
app.use(express.json());

app.post('/webhook', async (req, res) => {
    try {
        const payload = req.body;

        console.log('Webhook recibido:', payload);

        if (
            payload.event_type === 'INSERT' &&
            payload.record.bucket_id === 'yape_plin'
        ) {
            const fileName = payload.record.name; // Nombre del archivo en el bucket

            // Generar la URL pública de la imagen
            const { data, error } = await supabase
                .storage
                .from('yape_plin')
                .getPublicUrl(fileName);

            if (error) {
                console.error('Error al obtener la URL pública:', error);
                res.status(500).send('Error al procesar la imagen');
                return;
            }

            const imageUrl = data.publicUrl;
            console.log('URL de la nueva imagen:', imageUrl);

            // Ejecutar el archivo aplicacionocr.py con la URL como argumento
            const command = `python3 aplicacionocr.py '${imageUrl}'`;

            exec(command, (error, stdout, stderr) => {
                if (error) {
                    console.error('Error al ejecutar el script:', error);
                    res.status(500).send('Error al procesar la imagen');
                    return;
                }

                console.log('Salida del comando:', stdout);
                console.error('Errores del comando:', stderr);

                res.status(200).send('Imagen procesada con éxito');
            });
        } else {
            res.status(400).send('Evento no relevante para el bucket yape_plin');
        }
    } catch (error) {
        console.error('Error procesando el webhook:', error);
        res.status(500).send('Error interno del servidor');
    }
});

// Puerto donde estará escuchando la aplicación
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor escuchando en el puerto ${PORT}`);
});

