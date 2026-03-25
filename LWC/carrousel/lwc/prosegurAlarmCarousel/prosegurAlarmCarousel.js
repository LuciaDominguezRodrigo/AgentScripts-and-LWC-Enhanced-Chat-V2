import { LightningElement, track } from 'lwc';

export default class ProsegurProductCarousel extends LightningElement {
    @track currentIndex = 0;
    @track products = [];
    autoPlayTimer;

    connectedCallback() {
        this.initProducts();
        // this.startAutoPlay(); // Opcional
    }

    disconnectedCallback() {
        this.stopAutoPlay();
    }

    initProducts() {
        // Datos Mock internos (los que se ven bonitos)
        this.products = 
                    [
            {
                id: '1',
                title: 'Alarma Inteligente PetReady',
                description: 'Sensores de movimiento avanzados que distinguen entre el calor de tu mascota y una intrusión real. Evita falsas alarmas sin perder protección.',
                icon: 'utility:animal_and_nature',
                cssClass: 'product-card active',
                dotClass: 'dot active'
            },
            {
                id: '2',
                title: 'Cámara IA Pro-Visual',
                description: 'Cámaras con inteligencia artificial que filtran el movimiento de animales domésticos y solo te notifican cuando detectan una figura humana.',
                icon: 'utility:preview',
                cssClass: 'product-card',
                dotClass: 'dot'
            },
            {
                id: '3',
                title: 'Análisis Progresivo de Video',
                description: 'Sistema de verificación en la central que analiza los clips en tiempo real para descartar movimientos de mascotas, garantizando tranquilidad total.',
                icon: 'utility: video',
                cssClass: 'product-card',
                dotClass: 'dot'
            }
         
        ];
    }

    // --- LÓGICA DE NAVEGACIÓN ---

    updateClasses() {
        this.products = this.products.map((p, index) => {
            return {
                ...p,
                cssClass: index === this.currentIndex ? 'product-card active' : 'product-card',
                dotClass: index === this.currentIndex ? 'dot active' : 'dot'
            };
        });
    }

    next = () => {
        this.currentIndex = (this.currentIndex + 1) % this.products.length;
        this.updateClasses();
    };

    prev = () => {
        this.currentIndex = (this.currentIndex - 1 + this.products.length) % this.products.length;
        this.updateClasses();
    };

    goToSlide = (evt) => {
        const index = parseInt(evt.currentTarget.dataset.index, 10);
        this.currentIndex = index;
        this.updateClasses();
    };

    // --- LÓGICA DE INTERACCIÓN CON EL CHAT (NUEVO) ---

    handleSelection(event) {
        // Obtenemos el índice del producto clickado
        const index = parseInt(event.target.dataset.index, 10);
        const selectedProduct = this.products[index];

        if (selectedProduct) {
            // Construimos el mensaje
            const message = `Me interesa el producto: ${selectedProduct.title}`;
            console.log('Enviando al chat:', message);
            
            // Enviamos al chat
            this.safeSendTextMessage(message);
        }
    }

    /**
     * Envía un mensaje de texto al Bot actuando como el usuario.
     * Soporta tanto Embedded Service (Legacy) como MIAW (Messaging).
     */
    safeSendTextMessage(text) {
        const candidates = [
            // Enhanced Chat v2 (Einstein Bots web sdk / MIAW)
            () => window?.EinsteinBots?.sendTextMessage,
            // Messaging for In-App/Web (Legacy API en algunos contextos)
            () => window?.MessagingAPI?.sendTextMessage,
            // Embedded Service (Legacy Live Agent)
            // eslint-disable-next-line no-undef
            () => (typeof embeddedservice_configuration !== 'undefined' && embeddedservice_configuration?.util?.sendTextMessage) 
                    ? embeddedservice_configuration.util.sendTextMessage 
                    : undefined,
            // Fallback genérico directo
            () => window?.sendTextMessage
        ];

        let sent = false;
        for (const getter of candidates) {
            try {
                const fn = getter();
                if (typeof fn === 'function') {
                    const result = fn(text);
                    // Si devuelve promesa, capturamos errores silenciosamente
                    if (result && typeof result.then === 'function') {
                        result.catch(e => console.warn('Promise rejected en envío de mensaje', e));
                    }
                    sent = true;
                    break; // Si encontramos una función que existe, paramos de buscar
                }
            } catch (e) {
                console.warn('Error intentando enviar mensaje con candidato', e);
            }
        }
        
        if(!sent) {
            console.warn('⚠️ No se encontró ninguna API de chat disponible. Modo Debug:', text);
        }
    }

    // Funciones vacías por si se usan en el HTML
    startAutoPlay() {}
    stopAutoPlay() {}
    pauseTimer() {}
    resumeTimer() {}
}