/**
 * @description Service layer for Aquaservice Form.
 * Returns a single item to trigger the LWC in the chat.
 * @author Agentforce
 * @date 2026-03-03
 */
public with sharing class AquaserviceFormService {

    public class FormResponse {
        @AuraEnabled public String status;
        @AuraEnabled public String message;

        public FormResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }

    /**
     * @description Generates a single trigger item for the LWC.
     */
    public static List<FormResponse> getFormTrigger() {
        List<FormResponse> result = new List<FormResponse>();
        // Este registro "despierta" al componente en el chat
        result.add(new FormResponse('INIT', 'Cargando formulario de asistencia...'));
        return result;
    }
}