public with sharing class AquaserviceFormController {
    @AuraEnabled
    public static void saveForm(String nombre, String email, String pedido, String problema) {
        try {
            Case nuevoCaso = new Case();
            nuevoCaso.Subject = 'Incidencia Aquaservice: ' + pedido;
            nuevoCaso.Description = 'Nombre: ' + nombre + '\nProblema: ' + problema;
            nuevoCaso.SuppliedEmail = email;
            nuevoCaso.Origin = 'Web Chat';
            insert nuevoCaso;
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar: ' + e.getMessage());
        }
    }
}