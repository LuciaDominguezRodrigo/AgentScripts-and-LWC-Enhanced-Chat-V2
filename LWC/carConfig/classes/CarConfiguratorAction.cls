public with sharing class CarConfiguratorAction {

    // =============================
    // DTOs (Data Transfer Objects)
    // =============================
    // Clases que sirven para serializar / deserializar JSON
    // y para exponer datos a Lightning, Aura y Flow.

    @JsonAccess(serializable='always' deserializable='always')
    public class ColorDTO {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String hex { get; set; }
        @AuraEnabled public String imageURL { get; set; }

        public ColorDTO() {}
        public ColorDTO(String name, String hex, String imageURL) {
            this.name = name;
            this.hex = hex;
            this.imageURL = imageURL;
        }
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class VersionDTO {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String transmission { get; set; }
        @AuraEnabled public String fuel { get; set; }
        @AuraEnabled public String imageURL { get; set; }
        @AuraEnabled public List<ColorDTO> colors { get; set; }

        public VersionDTO() {}
        public VersionDTO(String id, String name, String transmission, String fuel, String imageURL, List<ColorDTO> colors) {
            this.id = id;
            this.name = name;
            this.transmission = transmission;
            this.fuel = fuel;
            this.imageURL = imageURL;
            this.colors = colors;
        }
    }

    // =============================
    // Estructuras para Flow / Agentforce
    // =============================
    // Estas clases permiten que la acción sea invocable desde Flows.

    public class ConfiguratorInput {
        @InvocableVariable(required=false label='Modelo de Coche' description='Ej: ASX (Opcional, por defecto devuelve ASX)')
        public String modelName;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class ConfiguratorOutput {
        @InvocableVariable(label='Datos del Configurador')
        public ConfiguratorData data;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class ConfiguratorData {
        @InvocableVariable(label='Lista de Versiones')
        public List<VersionDTO> versions;
    }


    // =============================
    // MÉTODOS INVOCABLES
    // =============================

    /**
     * Acción invocable desde Agentforce / Flow
     * @param inputs Lista de inputs (opcional)
     * @return Lista de ConfiguratorOutput con datos del configurador
     */
    @InvocableMethod(label='Get Car Configurator Data' description='Obtiene las versiones y colores disponibles para el configurador')
    public static List<ConfiguratorOutput> getConfiguratorData(List<ConfiguratorInput> inputs) {
        String model = (inputs != null && !inputs.isEmpty()) ? inputs[0]?.modelName : null;
        
        List<ConfiguratorOutput> outs = new List<ConfiguratorOutput>();
        ConfiguratorOutput out = new ConfiguratorOutput();
        ConfiguratorData configData = new ConfiguratorData();
        
        // Llamada a la lógica interna
        configData.versions = getVersionsInternal(model);
        
        out.data = configData;
        outs.add(out);
        return outs;
    }


    /**
     * Método @AuraEnabled para LWC directo
     * Se puede llamar desde un componente sin pasar por Flow
     */
    @AuraEnabled(cacheable=false)
    public static List<VersionDTO> getVersions(String modelName) {
        return getVersionsInternal(modelName);
    }

    // --- Lógica Interna (Mock Data de Mitsubishi ASX) ---
        
    private static List<VersionDTO> getVersionsInternal(String modelName) {
        List<VersionDTO> versions = new List<VersionDTO>();

        // URLs de imágenes reales
        String urlRojo = 'https://storm-39ff38d2b1fd39--c.vf.force.com/resource/1764599580000/intenseRojo';
        String urlBlanco = 'https://storm-39ff38d2b1fd39--c.vf.force.com/resource/1764599580000/intenseRojo';
        String urlNegro = 'https://scene7.mitsubishicars.com/is/image/mitsubishimotors/2024_Outlander_Sport_20_SE_Labrador_Black_Pearl_HERO_01?wid=1024&fmt=png-alpha';
        String urlGris = 'https://scene7.mitsubishicars.com/is/image/mitsubishimotors/2024_Outlander_Sport_20_SE_Mercury_Gray_Metallic_HERO_01?wid=1024&fmt=png-alpha';
        String urlAzul = 'https://scene7.mitsubishicars.com/is/image/mitsubishimotors/2024_Outlander_Sport_20_Trail_Edition_Electric_Blue_Metallic_HERO_01?wid=1024&fmt=png-alpha';

        // Definición de Objetos Color
        ColorDTO rojo = new ColorDTO('Rojo Diamond', '#D71920', urlRojo);
        ColorDTO blanco = new ColorDTO('Blanco Polar', '#FFFFFF', urlBlanco);
        ColorDTO negro = new ColorDTO('Negro Onyx', '#111111', urlNegro);
        ColorDTO gris = new ColorDTO('Gris Titanium', '#6B6F72', urlGris);
        ColorDTO azul = new ColorDTO('Azul Ocean', '#1D4ED8', urlAzul);

        // VERSION 1: Intense MT (Asignamos colores específicos)
        List<ColorDTO> colorsV1 = new List<ColorDTO>{ rojo, blanco, negro };
        versions.add(new VersionDTO(
            'asx-intense',
            'Mitsubishi ASX Intense',
            'Manual 6v',
            'Gasolina',
            urlRojo, // Imagen por defecto de la versión
            colorsV1
        ));

        // VERSION 2: Kaiteki CVT (Asignamos colores específicos)
        List<ColorDTO> colorsV2 = new List<ColorDTO>{ gris, azul, blanco };
        versions.add(new VersionDTO(
            'asx-kaiteki',
            'Mitsubishi ASX Kaiteki',
            'Automática CVT',
            'Híbrido',
            urlGris, // Imagen por defecto de la versión
            colorsV2
        ));

        return versions;
    }
}