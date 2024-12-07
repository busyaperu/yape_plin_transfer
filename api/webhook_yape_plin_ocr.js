// api/webhook_yape_plin_ocr.js

const { createClient } = require('@supabase/supabase-js');
const fetch = require('node-fetch');

// Inicializar Supabase
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_API_KEY = process.env.SUPABASE_API_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_API_KEY);

module.exports = async function handler(req, res) {
    if (req.method === 'POST') {
        try {
            const payload = req.body;

            console.log('Webhook recibido:', payload);

            if (
                payload.event_type === 'INSERT' &&
                payload.record.bucket_id === 'yapeplin-28d79' // o el nombre de tu bucket en Firebase Storage
            ) {
                const fileName = payload.record.name; // Nombre del archivo en el bucket

                // Generar la URL pública de la imagen
                const { data, error } = await supabase
                    .storage
                    .from('yape_plin')
                    .getPublicUrl(fileName);

                if (error) {
                    console.error('Error al obtener la URL pública:', error);
                    res.status(500).json({ message: 'Error al procesar la imagen' });
                    return;
                }

                const imageUrl = data.publicUrl;
                console.log('URL de la nueva imagen:', imageUrl);

                // Llamar a la función Python mediante HTTP
                const pythonResponse = await fetch('https://orc-funcion.vercel.app/api/webhook_yape_plin_ocr', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ imageUrl })
                });

                if (!pythonResponse.ok) {
                    const errorDetails = await pythonResponse.text();
                    console.error('Error desde el script Python:', errorDetails);
                    res.status(500).json({ message: 'Error al procesar la imagen con OCR' });
                    return;
                }

                const ocrResult = await pythonResponse.json();
                console.log('Resultado del OCR:', ocrResult);

                res.status(200).json({ message: 'Imagen procesada con éxito', data: ocrResult });
            } else {
                res.status(400).json({ message: 'Evento no relevante para el bucket yape_plin' });
            }
        } catch (error) {
            console.error('Error procesando el webhook:', error);
            res.status(500).json({ message: 'Error interno del servidor' });
        }
    } else {
        res.status(405).json({ message: 'Método no permitido' });
    }
};


