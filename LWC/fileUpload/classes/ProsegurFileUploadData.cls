/**
 * @description Clase contenedora para el Lightning Type.
 * Transporta toda la configuración en un solo String JSON para evitar problemas
 * de renderizado de listas en Agentforce.
 */
@JsonAccess(serializable='always' deserializable='always')
global class ProsegurFileUploadData {

    @AuraEnabled
    global String fileUploadJSON;

    /**
     * @description Constructor vacío requerido
     */
    global ProsegurFileUploadData() {
        this.fileUploadJSON = '{}';
    }

    /**
     * @description Constructor principal
     */
    global ProsegurFileUploadData(String jsonString) {
        this.fileUploadJSON = jsonString;
    }
}