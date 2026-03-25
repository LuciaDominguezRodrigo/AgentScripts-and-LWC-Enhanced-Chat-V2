global with sharing class ProsegurFileUploadInvocable {

    // -------- INPUTS --------
    global class Inputs {
        @InvocableVariable(label='Routable Id' description='ID del registro padre')
        global Id recordId;

        @InvocableVariable(label='Label' description='Título del botón (opcional)')
        global String label;
    }

    // -------- OUTPUTS --------
    global class Outputs {
        // Devolvemos el objeto Wrapper, NO variables sueltas
        @InvocableVariable(label='File Upload Data')
        global ProsegurFileUploadData fileData;

        public Outputs(ProsegurFileUploadData fileData) {
            this.fileData = fileData;
        }
    }

    // -------- MÉTODO PRINCIPAL --------
    @InvocableMethod(
        label='Show File Upload (JSON)'
        description='Genera la configuración de subida encapsulada en JSON para Agentforce'
    )
    global static List<Outputs> triggerUpload(List<Inputs> inputList) {
        List<Outputs> results = new List<Outputs>();

        for (Inputs inRec : inputList) {
            // 1. Construimos un mapa con todos los datos que necesita el LWC
            Map<String, Object> config = new Map<String, Object>();
            
            config.put('recordId', inRec.recordId);
            config.put('label', String.isBlank(inRec.label) ? 'Sube tu factura' : inRec.label);
            
            // Aquí puedes añadir configuraciones extra si quieres en el futuro
            config.put('acceptedFormats', new List<String>{'.pdf', '.jpg', '.png', '.jpeg'});

            // 2. Serializamos el mapa a un String JSON
            String jsonPayload = JSON.serialize(config);

            // 3. Empaquetamos en el objeto Data
            ProsegurFileUploadData dataWrapper = new ProsegurFileUploadData(jsonPayload);

            results.add(new Outputs(dataWrapper));
        }

        return results;
    }
}