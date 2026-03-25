/**
 * @description Utilidades para la gestión de subida de archivos en flujos de Chat/MIAW.
 * Crea registros contenedores para que el lightning-file-upload tenga un destino válido.
 * @author Agentforce
 * @group Prosegur Utils
 */
public without sharing class ProsegurFileUploadUtils {

    // --- ESTRUCTURAS DE DATOS PARA FLOW ---
    
    public class Inputs {
        @InvocableVariable(label='Contact ID' description='(Opcional) ID del contacto si se conoce')
        public String contactId;

        @InvocableVariable(label='Subject' description='Asunto del caso contenedor (Ej: Factura subida)')
        public String subject;
    }

    public class Outputs {
        @InvocableVariable(label='Record ID' description='El ID del registro creado para adjuntar el archivo')
        public String recordId;

        public Outputs(String recordId) {
            this.recordId = recordId;
        }
    }

    // --- MÉTODO INVOCABLE ---

    @InvocableMethod(label='Create Upload Container' description='Crea un Caso temporal para permitir la subida de archivos via LWC')
    public static List<Outputs> createUploadContainer(List<Inputs> inputList) {
        List<Outputs> results = new List<Outputs>();
        List<Case> casesToInsert = new List<Case>();

        // 1. Preparar los casos
        for (Inputs input : inputList) {
            Case newCase = new Case();
            // Asignamos un asunto por defecto si no viene informado
            newCase.Subject = String.isNotBlank(input.subject) 
                ? input.subject 
                : 'Recepción de Documento - ' + System.now();
            
            newCase.Status = 'New';
            newCase.Origin = 'Web'; // O el origen que prefieras para identificar estos casos
            
            // Si tenemos el contacto, lo enlazamos
            if (String.isNotBlank(input.contactId)) {
                newCase.ContactId = input.contactId;
            }

            casesToInsert.add(newCase);
        }

        // 2. Insertar en base de datos
        if (!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
            } catch (Exception e) {
                System.debug('Error creando contenedor de archivo: ' + e.getMessage());
                // En caso de error, podríamos devolver null, pero el LWC fallará.
                // Lo ideal es manejar la excepción en el Flow.
            }
        }

        // 3. Preparar respuesta
        for (Case c : casesToInsert) {
            results.add(new Outputs(c.Id));
        }

        return results;
    }
}