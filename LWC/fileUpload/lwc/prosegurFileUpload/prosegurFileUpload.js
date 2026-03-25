import { LightningElement, api, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';

export default class ProsegurFileUpload extends LightningElement {
    @api fileUploadJSON; 
    @track recordId; 
    @track label = 'Adjuntar Archivos';
    @track showUpload = true;
    @track isUploading = false;

    connectedCallback() {
        if (this.fileUploadJSON) {
            try {
                const config = typeof this.fileUploadJSON === 'string' 
                    ? JSON.parse(this.fileUploadJSON) 
                    : this.fileUploadJSON;
                this.recordId = config.recordId || USER_ID;
                if (config.label) this.label = config.label;
            } catch (e) { console.error('Error JSON', e); }
        }
    }

    handleUploadFinished(event) {
        this.isUploading = true;

        // Una vez que Salesforce confirma que el archivo subió:
        setTimeout(() => {
            this.isUploading = false;
            this.showUpload = false;
            
            // MANDAR MENSAJE AUTOMÁTICO
            this.sendAutomaticMessage();
        }, 800);
    }

    sendAutomaticMessage() {
        // Esta es la frase que el Bot debe reconocer para activar el análisis
        const TEXTO_DISPARADOR = "Archivo subido correctamente. Analizar factura.";

        // Intentamos enviar el mensaje por diferentes métodos dependiendo de dónde esté el chat
        try {
            // Método 1: Para Embedded Service Chat (Standard)
            const messageEvent = new CustomEvent('setCustomEvent', {
                detail: {
                    messageText: TEXTO_DISPARADOR,
                    callback: (data) => { console.log('Mensaje enviado'); }
                },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(messageEvent);

            // Método 2: Inyección directa en el API de Mensajería de Ventana
            if (window.embedded_svc) {
                window.embedded_svc.postMessage("sendTextMessage", TEXTO_DISPARADOR);
            }
        } catch (err) {
            console.error('No se pudo enviar el mensaje al chat:', err);
        }
    }
}