import { LightningElement, track, api } from 'lwc';
// Importamos la acción de guardado (debes crear esta clase Apex, ver paso 2)
import saveForm from '@salesforce/apex/AquaserviceFormController.saveForm';

export default class AquaserviceForm extends LightningElement {
    @api formData; 
    @track currentIndex = 0;
    @track isSubmitted = false; // Para ocultar el formulario al terminar
    @track steps = [
        { name: 'nombre', label: '¿Cuál es tu nombre?', type: 'text', placeholder: 'Nombre...', value: '', isFirst: true },
        { name: 'email', label: 'Email de contacto', type: 'email', placeholder: 'tu@email.com', value: '' },
        { name: 'pedido', label: 'ID Pedido / Oficina', type: 'text', placeholder: 'Referencia...', value: '' },
        { name: 'problema', label: '¿Qué sucede?', type: 'text', placeholder: 'Describe el problema...', value: '', isLast: true }
    ];

    connectedCallback() { this.updateStepClasses(); }

    get progressStyle() {
        const percent = ((this.currentIndex + 1) / this.steps.length) * 100;
        return `width: ${percent}%`;
    }

    handleInputChange(event) {
        const name = event.target.dataset.name;
        const value = event.target.value;
        this.steps = this.steps.map(step => {
            if (step.name === name) return { ...step, value: value };
            return step;
        });
        this.updateStepClasses();
    }

    updateStepClasses() {
        this.steps = this.steps.map((step, index) => ({
            ...step,
            displayIndex: index + 1,
            cssClass: index === this.currentIndex ? 'form-card active' : 'form-card',
            isInvalid: !step.value || step.value.length < 2
        }));
    }

    next() { if (this.currentIndex < this.steps.length - 1) { this.currentIndex++; this.updateStepClasses(); } }
    prev() { if (this.currentIndex > 0) { this.currentIndex--; this.updateStepClasses(); } }

    // FUNCIÓN DE ENVÍO MODIFICADA
 // Eliminamos 'async' porque no queremos esperar la promesa
    handleSubmit() {
        // 1. Extraemos los valores
        const fields = {};
        this.steps.forEach(s => { fields[s.name] = s.value; });

        // 2. Feedback visual INMEDIATO
        this.isSubmitted = true; // Oculta el formulario ya
        this.safeSendTextMessage('Formulario enviado'); // Envía el texto al chat ya

        // 3. Llamada a Apex en "segundo plano" (sin await)
        saveForm({
            nombre: fields.nombre,
            email: fields.email,
            pedido: fields.pedido,
            problema: fields.problema
        })
        .then(() => {
            console.log('Guardado en Salesforce correctamente en segundo plano.');
        })
        .catch(error => {
            // Si falla, el usuario ya no lo ve, pero tú puedes trackearlo
            console.error('Error asíncrono al guardar:', error);
        });
    }
    safeSendTextMessage(text) {
        const candidates = [
            () => window?.EinsteinBots?.sendTextMessage,
            () => window?.MessagingAPI?.sendTextMessage,
            () => (typeof embeddedservice_configuration !== 'undefined' && embeddedservice_configuration?.util?.sendTextMessage) 
                    ? embeddedservice_configuration.util.sendTextMessage 
                    : undefined,
            () => window?.sendTextMessage
        ];

        let sent = false;
        for (const getter of candidates) {
            try {
                const fn = getter();
                if (typeof fn === 'function') {
                    fn(text); 
                    sent = true;
                    break;
                }
            } catch (e) { }
        }
        
        if(!sent) {
            console.warn('⚠️ No se detectó canal de chat activo:', text);
        }
    }
}