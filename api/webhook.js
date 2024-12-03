// api/webhook.js
export default async function handler(req, res) {
    if (req.method === 'POST') {
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
                    res.status(500).json({ message: 'Error al procesar la imagen' });
                    return;
                }

                const imageUrl = data.publicUrl;
                console.log('URL de la nueva imagen:', imageUrl);

                // Ejecutar el archivo aplicacionocr.py con la URL como argumento
                const command = `python3 aplicacionocr.py '${imageUrl}'`;

                exec(command, (error, stdout, stderr) => {
                    if (error) {
                        console.error('Error al ejecutar el script:', error);
                        res.status(500).json({ message: 'Error al procesar la imagen' });
                        return;
                    }

                    console.log('Salida del comando:', stdout);
                    console.error('Errores del comando:', stderr);

                    res.status(200).json({ message: 'Imagen procesada con éxito' });
                });
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
}


