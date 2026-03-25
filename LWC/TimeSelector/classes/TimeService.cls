public with sharing class ProsegurTimeService {

    // El objeto de datos (DTO) que el LWC recibirá
    public class TimeSlotDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String status;
        
        public TimeSlotDTO() {}
        
        // Constructor simple
        public TimeSlotDTO(String id, String status) {
            this.id = id;
            this.status = status;
        }
    }

    /**
     * @description Genera un ÚNICO ítem "dummy".
     * Esto engaña al Flow/Agentforce: Devuelve una lista con 1 elemento.
     * El LWC ignorará los datos de este elemento y mostrará su propia lógica de calendario.
     */
    public static List<TimeSlotDTO> getMockTimeSlot() {
        List<TimeSlotDTO> result = new List<TimeSlotDTO>();
        
        // Creamos un ítem "trigger" solo para disparar el LWC
        result.add(new TimeSlotDTO('trigger-lwc', 'open'));

        return result;
    }
}
