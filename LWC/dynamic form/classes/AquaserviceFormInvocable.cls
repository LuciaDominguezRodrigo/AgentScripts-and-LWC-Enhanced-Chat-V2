/**
 * @description Invocable Apex for Agentforce to launch the Aquaservice Form LWC.
 * @author Agentforce
 * @date 2026-03-03
 */
public with sharing class AquaserviceFormInvocable {


    public class Inputs {


        @InvocableVariable(label='dummyInput' description='Título del botón (opcional)')
        public String label;
    }
    public class Outputs {
        @InvocableVariable(label='Form Data' description='Trigger data for the LWC')
        public List<AquaserviceFormService.FormResponse> formData;

        public Outputs(List<AquaserviceFormService.FormResponse> formData) {
            this.formData = formData;
        }
    }

    @InvocableMethod(
        label='Launch Aquaservice Form' 
        description='Displays the interactive form carousel in the chat'
    )
    public static List<Outputs> launchForm(List<Inputs> requests) {
        List<Outputs> results = new List<Outputs>();
        
        // Obtenemos el disparador del servicio
        List<AquaserviceFormService.FormResponse> triggerData = AquaserviceFormService.getFormTrigger();
        
        results.add(new Outputs(triggerData));
        return results;
    }
}