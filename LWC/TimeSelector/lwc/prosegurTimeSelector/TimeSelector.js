import { LightningElement, track, api } from 'lwc';

export default class TimeSelector extends LightningElement {
    @api selectedDate = '';
    @api selectedTime = '';
    
    @track step = 1; 

    @track currentMonth = new Date().getMonth();
    @track currentYear = new Date().getFullYear();
    
    weekdays = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
              'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    // CONFIGURACIÓN: Festivos y horas bloqueadas
    holidays = ['2026-01-01', '2026-05-01', '2026-12-25', '2024-02-15'];
    blockedHours = [14, 18]; 

    @track days = [];
    @track availableHours = [];
    
    connectedCallback() {
        this.generateCalendar();
        this.generateAvailableHours();
    }

    get showCalendar() { return this.step === 1; }
    get showTime() { return this.step === 2; }
    get showConfirmation() { return this.step === 3; }
    get currentMonthYear() { return `${this.months[this.currentMonth]} ${this.currentYear}`; }

    generateCalendar() {
        const firstDay = new Date(this.currentYear, this.currentMonth, 1);
        const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0);
        const daysInMonth = lastDay.getDate();
        const startingDayOfWeek = firstDay.getDay(); 
        const daysArray = [];
        
        for (let i = 0; i < startingDayOfWeek; i++) { 
            daysArray.push({ dayNumber: '', date: '', isCurrentMonth: false, class: 'day-cell empty' }); 
        }

        for (let day = 1; day <= daysInMonth; day++) {
            const dateStr = `${this.currentYear}-${String(this.currentMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            const dateObj = new Date(dateStr);
            const isSunday = dateObj.getDay() === 0;
            const isHoliday = this.holidays.includes(dateStr);
            const isSelected = dateStr === this.selectedDate;

            daysArray.push({ 
                dayNumber: day, 
                date: dateStr, 
                class: this.computeDayClass(isSunday, isHoliday, isSelected)
            });
        }
        this.days = daysArray;
    }
    
    generateAvailableHours() {
        const hours = [];
        for (let i = 9; i <= 19; i++) {
            const isBlocked = this.blockedHours.includes(i);
            const isSelected = i.toString() === this.selectedTime;
            
            let cssClass = 'time-slot';
            if (isSelected) cssClass += ' selected';
            else if (isBlocked) cssClass += ' disabled';

            hours.push({
                val: i,
                label: `${i}:00`,
                class: cssClass
            });
        }
        this.availableHours = hours;
    }

    computeDayClass(isSunday, isHoliday, isSelected) {
        if (isSelected) return 'day-cell selected';
        if (isHoliday) return 'day-cell holiday disabled';
        if (isSunday) return 'day-cell sunday disabled';
        return 'day-cell available';
    }

    previousMonth() {
        this.currentMonth--;
        if (this.currentMonth < 0) { this.currentMonth = 11; this.currentYear--; }
        this.generateCalendar();
    }
    
    nextMonth() {
        this.currentMonth++;
        if (this.currentMonth > 11) { this.currentMonth = 0; this.currentYear++; }
        this.generateCalendar();
    }
    
    selectDate(event) {
        const date = event.target.dataset.date;
        const classList = event.target.classList;

        if (date && !classList.contains('disabled')) {
            this.selectedDate = date;
            this.selectedTime = ''; 
            this.generateCalendar(); 
            setTimeout(() => { this.step = 2; this.generateAvailableHours(); }, 300);
        }
    }
    
    selectTime(event) {
        const hour = event.target.dataset.hour;
        const classList = event.target.classList;

        if (hour && !classList.contains('disabled')) {
            this.selectedTime = hour;
            this.generateAvailableHours(); // Regenerar para ver selección visual
            this.step = 3; 
        }
    }

    handleBack() {
        if (this.step > 1) {
            this.step--;
            if (this.step === 1) this.generateCalendar();
            if (this.step === 2) this.generateAvailableHours();
        }
    }

    handleConfirm() {
        if (this.selectedDate && this.selectedTime) {
            // Lógica de envío original
            const message = `He seleccionado la fecha ${this.selectedDate} a las ${this.selectedTime}:00`;
            console.log('Enviando al chat:', message);
            
            this.safeSendTextMessage(message);
        }
    }

    safeSendTextMessage(text) {
        const candidates = [
            () => window?.EinsteinBots?.sendTextMessage,
            () => window?.MessagingAPI?.sendTextMessage,
            // eslint-disable-next-line no-undef
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
            } catch (e) {
                // Ignore
            }
        }
        if(!sent) console.warn('⚠️ No se encontró API de chat. Mensaje:', text);
    }
}