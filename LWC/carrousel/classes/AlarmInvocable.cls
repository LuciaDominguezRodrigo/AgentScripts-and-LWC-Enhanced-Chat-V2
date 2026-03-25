/**
 * @description Invocable Apex for Flow to provide mock alarms and carousel settings to LWC.
 * Returns a response envelope that can be passed to the LWC via attributes.
 * Built with enums, DTOs, and exception handling patterns.
 * @author Agentforce
 * @group  Alarming
 * @date 2026-01-15
 */
public with sharing class AlarmInvocable {
    /**
     * @description Inputs accepted by the invocable action.
     * Use Flow inputs to drive the amount of alarms and autoplay settings.
     */
    public class Inputs {
        @InvocableVariable(required=false label='Number of Alarms' description='How many alarms to return (1..50)') 
        public Integer count;

        @InvocableVariable(required=false label='Autoplay' description='Whether the carousel should autoplay')
        public Boolean autoplay;

        @InvocableVariable(required=false label='Interval (ms)' description='Autoplay interval in milliseconds (500..60000)')
        public Integer intervalMs;
    }

    /**
     * @description Output variables exposed to Flow.
     * LWC can bind to these values via Flow resources.
     */
    public class Outputs {
        @InvocableVariable(label='Alarms' description='List of alarm DTOs for the carousel')
        public List<AlarmService.AlarmDTO> alarms;

        @InvocableVariable(label='Autoplay' description='Autoplay flag for the carousel')
        public Boolean autoplay;

        @InvocableVariable(label='Interval (ms)' description='Autoplay interval in milliseconds')
        public Integer intervalMs;

        public Outputs(List<AlarmService.AlarmDTO> alarms, Boolean autoplay, Integer intervalMs) {
            this.alarms = alarms;
            this.autoplay = autoplay;
            this.intervalMs = intervalMs;
        }
    }

    /**
     * @description Invocable entrypoint for Flow. Accepts a list of inputs (bulk-safe) and
     * returns a corresponding list of outputs preserving order.
     */
    @InvocableMethod(label='Get  Mock Alarms' description='Returns mock alarms and settings for the  Alarm Carousel')
    public static List<Outputs> getAlarms(List<Inputs> inputList) {
        // Return-early if no inputs
        if (inputList == null || inputList.isEmpty()) {
            return new List<Outputs>();
        }

        List<Outputs> results = new List<Outputs>();
        // Bulk-safe loop, but all operations are CPU-only (no SOQL/DML).
        for (Inputs inRec : inputList) {
            try {
                AlarmService.AlarmResponse resp = AlarmService.getMockAlarmsWithSettings(
                    inRec == null ? null : inRec.count,
                    inRec == null ? null : inRec.autoplay,
                    inRec == null ? null : inRec.intervalMs
                );
                results.add(new Outputs(resp.alarms, resp.autoplay, resp.intervalMs));
            } catch (Exception e) {
                // Graceful error handling for Flow: return empty alarms but keep defaults
                List<AlarmService.AlarmDTO> empty = new List<AlarmService.AlarmDTO>();
                results.add(new Outputs(empty, false, 5000));
            }
        }
        return results;
    }
}