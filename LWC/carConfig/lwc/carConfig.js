import { LightningElement, track, api } from 'lwc';

export default class ChatCarConfigurator extends LightningElement {

    // =============================
    // ESTADO DEL COMPONENTE (STATE)
    // =============================

    // Controla el paso del wizard:
    // 1 = selección de versión
    // 2 = selección de color
    @track step = 1;

    // Guarda el ID de la versión seleccionada
    // Ej: 'asx-intense'
    @track selectedVersionId = '';

    // Guarda el nombre del color seleccionado
    // Ej: 'Rojo Diamond'
    @track selectedColorName = '';

    // Datos Mock
    versions = [
        {
            id: 'asx-intense',
            name: 'Mitsubishi ASX Intense',
            transmission: 'Manual 6v',
            fuel: 'Gasolina',
            imageURL: 'https://images.unsplash.com/photo-1715372028425-c733b484e80e?q=80&w=2673&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            colors: [
                { name: 'Rojo Diamond', hex: '#D71920', imageURL: 'https://images.unsplash.com/photo-1606455964809-b169439bb58f?q=80&w=1287&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' },
                { name: 'Blanco Polar', hex: '#FFFFFF', imageURL: 'https://images.unsplash.com/photo-1715412098852-eee232c23a07?q=80&w=3734&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' },
                { name: 'Negro Onyx', hex: '#111111', imageURL: 'https://images.unsplash.com/photo-1594978100646-ccd2ae32b711?q=80&w=3451&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' }
            ]
        },
        {
            id: 'asx-kaiteki',
            name: 'Mitsubishi ASX Kaiteki',
            transmission: 'Auto CVT',
            fuel: 'Híbrido',
            imageURL: 'https://images.unsplash.com/photo-1706509230541-2c1c4e1272b1?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            colors: [
                { name: 'Gris Titanium', hex: '#6B6F72', imageURL: 'https://images.unsplash.com/photo-1706509230541-2c1c4e1272b1?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' },
                { name: 'Azul Ocean', hex: '#1D4ED8', imageURL: 'https://images.unsplash.com/photo-1628684014602-88da45adfb43?q=80&w=3024&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D' }
            ]
        }
    ];

    // =============================
    // GETTERS DE CONTROL DE UI
    // =============================

    // Indica si estamos en el paso 1
    get isStep1() { return this.step === 1; }

    // Indica si estamos en el paso 2
    get isStep2() { return this.step === 2; }

    // Devuelve true si hay una versión seleccionada
    get isVersionSelected() { return !!this.selectedVersionId; }


    // Título dinámico del componente
    // Paso 1: título genérico
    // Paso 2: nombre de la versión seleccionada
    get headerTitle() {
        if(this.step === 1) return 'Personaliza tu vehículo';
        return this.currentVersion ? this.currentVersion.name : 'Selecciona color';
    }

    get versionOptions() {
        return this.versions.map(v => ({ label: v.name, value: v.id }));
    }

    // Devuelve el objeto completo de la versión seleccionada
    get currentVersion() {
        return this.versions.find(v => v.id === this.selectedVersionId);
    }

    get currentTransmission() { return this.currentVersion ? this.currentVersion.transmission : '--'; }
    get currentFuel() { return this.currentVersion ? this.currentVersion.fuel : '--'; }


    // ==================================================
    // LÓGICA DE IMAGEN DINÁMICA
    // ==================================================
    // Prioridad:
    // 1. Imagen del color seleccionado
    // 2. Imagen base de la versión
    // 3. Imagen fallback genérica
    get currentImageUrl() {
        // 1. Si hay color seleccionado, mostramos coche de ese color
        if (this.selectedColorName && this.currentVersion) {
            const colorObj = this.currentVersion.colors.find(c => c.name === this.selectedColorName);
            if (colorObj) return colorObj.imageURL;
        }
        // 2. Si hay versión, mostramos coche de la versión
        if (this.currentVersion) return this.currentVersion.imageURL;
        // 3. Fallback genérico
        return this.versions[0].imageURL;
    }

    get colorOptionsWithState() {
        if (!this.currentVersion) return [];
        return this.currentVersion.colors.map(c => {
            const isSelected = c.name === this.selectedColorName;
            return {
                ...c,
                optionClass: `color-option ${isSelected ? 'selected' : ''}`,
                style: `background-color: ${c.hex}`
            };
        });
    }

    get isNextDisabled() {
        if (this.step === 1) return !this.selectedVersionId;
        if (this.step === 2) return !this.selectedColorName;
        return true;
    }

    // Texto dinámico del botón principal
    get nextLabel() {
        return this.step === 1 ? 'Siguiente' : 'Finalizar y Enviar';
    }

    // =============================
    // HANDLERS DE EVENTOS
    // =============================

    // Cuando el usuario selecciona una versión
    handleVersionChange(event) {
        this.selectedVersionId = event.detail.value;
        this.selectedColorName = ''; // Reset color para evitar inconsistencias
    }

    handleColorSelect(event) {
        const color = event.currentTarget.dataset.color;
        this.selectedColorName = color;
    }

    // Navegación hacia adelante
    nextStep() {
        if (this.step === 1) {
            this.step = 2;
        } else {
            // FIN DEL WIZARD: Enviamos la selección al Chat
            this.sendConfigurationToAgent();
        }
    }

    prevStep() {
        if (this.step === 2) this.step = 1;
    }


    // =============================
    // ENVÍO DE MENSAJE AL CHAT
    // =============================

    // Construye el mensaje final y lo envía
    sendConfigurationToAgent() {
        const message = `He configurado un ${this.currentVersion.name} en color ${this.selectedColorName}`;
        console.log('Enviando configuración:', message);
        this.sendMessageToChat(message);
    }

    sendMessageToChat(text) {
        // Usamos try/catch para evitar errores si no estamos dentro del chat real
        try {
            // Verificamos si existe la API de Embedded Service 
            // eslint-disable-next-line no-undef
            if (typeof embeddedservice_configuration !== 'undefined' && 
                // eslint-disable-next-line no-undef
                embeddedservice_configuration.util && 
                // eslint-disable-next-line no-undef
                embeddedservice_configuration.util.sendTextMessage) {
                
                // ENVIAR MENSAJE
                // eslint-disable-next-line no-undef
                embeddedservice_configuration.util.sendTextMessage(text);
                
            } else {
                // Fallback para MIAW
                this.safeSendTextMessageFallback(text);
            }
        } catch (error) {
            console.error('Error al enviar mensaje:', error);
        }
    }

    // --- COMUNICACIÓN CON EL CHAT

    sendSelectionToChat() {
        const message = `He configurado un ${this.currentVersion.name} en color ${this.selectedColorName}`;
        this.safeSendTextMessage(message);
    }

    safeSendTextMessage(text) {
        const candidates = [
            // Enhanced Chat v2 (Einstein Bots web sdk)
            () => window?.EinsteinBots?.sendTextMessage,
            // Messaging for In-App/Web (legacy/messaging)
            () => window?.MessagingAPI?.sendTextMessage,
            // Fallback directo
            () => window?.sendTextMessage
        ];

        let sent = false;
        for (const getter of candidates) {
            try {
                const fn = getter();
                if (typeof fn === 'function') {
                    const result = fn(text);
                    if (result && typeof result.then === 'function') {
                        result.catch(e => console.warn('Promise rejected', e));
                    }
                    sent = true;
                    break;
                }
            } catch (e) {
                console.warn('Error en handler', e);
            }
        }
        
        if(!sent) {
            console.log('Modo Debug (No API encontrada): ', text);
            // Opcional: Mostrar un toast si estás probando fuera del chat
        }
    }
}