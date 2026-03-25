public with sharing class TimeInvocable {

    /**
     * @description Inputs aceptados por la acción. 
     * Añadimos esto para que Agentforce detecte que la acción recibe parámetros.
     */
    public class Input {
        @InvocableVariable(required=false label='Trigger ID' description='Optional dummy input to trigger the action')
        public String triggerId;
    }

    /**
     * @description Clase envoltorio para la salida.
     */
    public class Output {
        @InvocableVariable(label='Time Slots' description='List of time slots to render')
        public List<TimeService.TimeSlotDTO> timeSlots;

        public Output(List<TimeService.TimeSlotDTO> slots) {
            this.timeSlots = slots;
        }
    }

    /**
     * @description Esta es la acción que seleccionas en el Agentforce/Flow.
     * Ahora acepta una lista de Inputs, aunque no hagamos nada con ellos.
     */
    @InvocableMethod(label='Show Time Selector Component' description='Displays the interactive calendar for time selection')
    public static List<Output> showTimeSelector(List<Input> inputs) {
        
        List<Output> results = new List<Output>();

        // Si por alguna razón la lista es nula o vacía (raro en Flows), devolvemos vacío
        if (inputs == null || inputs.isEmpty()) {
            return results;
        }

        // Obtenemos el dummy record del servicio (solo una vez para reutilizarlo)
        List<TimeService.TimeSlotDTO> slots = TimeService.getMockTimeSlot();

        // Iteramos sobre los inputs para devolver exactamente el mismo número de respuestas
        // Esto es obligatorio en Apex Invocable Methods (Bulkification)
        for (Input input : inputs) {
            results.add(new Output(slots));
        }
        
        return results;
    }
}
