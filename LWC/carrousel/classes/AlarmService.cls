/**
 * @description Service layer for providing mock alarm data.
 * MODIFIED: Returns a SINGLE dummy item to force the Flow Loop to run only once.
 * The LWC handles the real product data internally.
 * @author Agentforce
 * @group  Alarming
 * @date 2026-01-15
 */
public with sharing class AlarmService {

    public enum SEVERITY {
        CRITICAL, HIGH, MEDIUM, LOW
    }

    public virtual class AlarmDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public SEVERITY severity;
        @AuraEnabled public String eventTime;
        @AuraEnabled public String location;
        @AuraEnabled public String sensor;
        @AuraEnabled public String priority;

        public AlarmDTO withId(String v)         { this.id = v; return this; }
        public AlarmDTO withTitle(String v)      { this.title = v; return this; }
        public AlarmDTO withDescription(String v){ this.description = v; return this; }
        public AlarmDTO withSeverity(SEVERITY v) { this.severity = v; return this; }
        public AlarmDTO withEventTime(String v)  { this.eventTime = v; return this; }
        public AlarmDTO withLocation(String v)   { this.location = v; return this; }
        public AlarmDTO withSensor(String v)     { this.sensor = v; return this; }
        public AlarmDTO withPriority(String v)   { this.priority = v; return this; }

        public AlarmDTO of(String id, String title, String description, SEVERITY severity, String eventTime, String location, String sensor, String priority) {
            AlarmDTO dto = new AlarmDTO();
            dto.id = id;
            dto.title = title;
            dto.description = description;
            dto.severity = severity;
            dto.eventTime = eventTime;
            dto.location = location;
            dto.sensor = sensor;
            dto.priority = priority;
            return dto;
        }
    }

    public virtual class AlarmResponse {
        @AuraEnabled public List<AlarmDTO> alarms;
        @AuraEnabled public Boolean autoplay;
        @AuraEnabled public Integer intervalMs;

        public AlarmResponse(List<AlarmDTO> alarms, Boolean autoplay, Integer intervalMs) {
            this.alarms = alarms;
            this.autoplay = autoplay;
            this.intervalMs = intervalMs;
        }
    }

    /**
     * @description Generates a SINGLE mock item.
     * We ignore the 'count' input to force the UI to render exactly once.
     */
    public static List<AlarmDTO> getMockAlarms(Integer count) {
        // TRUCO: Ignoramos el 'count' y devolvemos siempre UNA lista con UN elemento.
        // Esto engaña al Flow: El bucle da 1 vuelta -> El componente sale 1 vez.
        // El componente (LWC) ignorará estos datos y usará los suyos internos (Doble Garantía, etc).
        
        List<AlarmDTO> result = new List<AlarmDTO>();
        
        // Creamos un ítem "tonto" solo para cumplir con el Flow
        AlarmDTO dummy = new AlarmDTO()
            .withId('trigger-lwc')
            .withTitle('Showcase')
            .withDescription('Loading Internal Products...')
            .withSeverity(SEVERITY.LOW);
            
        result.add(dummy);

        return result;
    }

    /**
     * @description Public method wrapper.
     */
    public static AlarmResponse getMockAlarmsWithSettings(Integer count, Boolean autoplay, Integer intervalMs) {
        // Forzamos count a 1 aquí también, por si acaso.
        List<AlarmDTO> alarms = getMockAlarms(1);
        
        // Configuraciones por defecto
        Boolean safeAutoplay = (autoplay == null) ? false : autoplay;
        Integer safeInterval = (intervalMs == null) ? 5000 : intervalMs;

        return new AlarmResponse(alarms, safeAutoplay, safeInterval);
    }
}