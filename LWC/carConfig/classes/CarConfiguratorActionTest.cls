@IsTest
private class CarConfiguratorActionTest {

    /**
     * Test para el método @AuraEnabled que usa el LWC directamente.
     * Valida que devuelva la lista de versiones y la estructura de colores.
     */
    @IsTest
    static void testGetVersions_AuraEnabled() {
        Test.startTest();
        // Llamamos al método directo (simulando LWC)
        List<CarConfiguratorAction.VersionDTO> versions = CarConfiguratorAction.getVersions(null);
        Test.stopTest();

        // Validaciones generales
        System.assertNotEquals(null, versions, 'La lista de versiones no debería ser nula');
        System.assert(versions.size() >= 2, 'Debería devolver al menos 2 versiones (Mock Data)');

        // Validar estructura de la primera versión
        CarConfiguratorAction.VersionDTO first = versions[0];
        System.assert(String.isNotBlank(first.id), 'El ID de la versión debe existir');
        System.assert(String.isNotBlank(first.name), 'El Nombre de la versión debe existir');
        System.assert(String.isNotBlank(first.transmission), 'La Transmisión debe existir');
        System.assert(String.isNotBlank(first.fuel), 'El Combustible debe existir');
        System.assert(String.isNotBlank(first.imageURL), 'La URL de imagen debe existir');

        // Validar estructura de los colores anidados
        System.assertNotEquals(null, first.colors, 'La lista de colores no debe ser nula');
        System.assert(first.colors.size() > 0, 'Debería tener al menos un color disponible');
        
        CarConfiguratorAction.ColorDTO firstColor = first.colors[0];
        System.assert(String.isNotBlank(firstColor.name), 'El nombre del color debe existir');
        System.assert(String.isNotBlank(firstColor.hex), 'El código hex del color debe existir');
        System.assert(String.isNotBlank(firstColor.imageURL), 'La URL de imagen del color debe existir');
    }

    /**
     * Test para el método @InvocableMethod que usa Agentforce o Flows.
     * Valida la estructura de entrada/salida compleja (List<Output> -> Data -> Versions).
     */
    @IsTest
    static void testGetConfiguratorData_Invocable() {
        // Preparar input del Flow/Agente
        CarConfiguratorAction.ConfiguratorInput input = new CarConfiguratorAction.ConfiguratorInput();
        input.modelName = 'ASX'; // Dato opcional

        List<CarConfiguratorAction.ConfiguratorInput> inputList = new List<CarConfiguratorAction.ConfiguratorInput>();
        inputList.add(input);

        Test.startTest();
        // Llamada al método invocable
        List<CarConfiguratorAction.ConfiguratorOutput> outputs = CarConfiguratorAction.getConfiguratorData(inputList);
        Test.stopTest();

        // Validaciones de la estructura de respuesta del Agente
        System.assertNotEquals(null, outputs, 'El output invocable no debe ser nulo');
        System.assertEquals(1, outputs.size(), 'Debe devolver un elemento de salida');
        
        CarConfiguratorAction.ConfiguratorOutput output = outputs[0];
        System.assertNotEquals(null, output.data, 'El objeto data interno no debe ser nulo');
        System.assertNotEquals(null, output.data.versions, 'La lista de versiones interna no debe ser nula');
        System.assert(output.data.versions.size() > 0, 'Debe contener datos de versiones');
    }

    /**
     * Test de robustez: Comprobar qué pasa si el input al invocable es nulo o vacío.
     */
    @IsTest
    static void testGetConfiguratorData_NullInput() {
        Test.startTest();
        // Llamada con null para asegurar que no rompe (Null Pointer Exception)
        List<CarConfiguratorAction.ConfiguratorOutput> outputs = CarConfiguratorAction.getConfiguratorData(null);
        Test.stopTest();

        System.assertNotEquals(null, outputs, 'Debería devolver una lista vacía o inicializada, no null');
        System.assertEquals(1, outputs.size(), 'Debería devolver estructura por defecto aunque no haya input');
        System.assert(outputs[0].data.versions.size() > 0, 'Debería devolver datos mock por defecto');
    }
}